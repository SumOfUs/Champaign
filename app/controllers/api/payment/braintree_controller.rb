# frozen_string_literal: true

class Api::Payment::BraintreeController < PaymentController
  include ExceptionHandler
  protect_from_forgery with: :exception, prepend: true
  skip_before_action :verify_authenticity_token, raise: false
  before_action :check_api_key, only: [:refund]
  # before_action :verify_bot, only: [:transaction]

  def token
    @merchant_account_id = unsafe_params[:merchantAccountId]
    render json: { token: ::Braintree::ClientToken.generate(merchant_account_id: @merchant_account_id) }
  end

  def express_payment
    @page = Page.find(params[:page_id])
    @follow_up_url = ''

    begin
      @follow_up_url = PageFollower.new_from_page(
        @page
      ).follow_up_path
    rescue StandardError
    end

    begin
      @process_one_click ||= PaymentProcessor::Braintree::OneClickFromUri.new(
        params.to_unsafe_hash,
        page: @page,
        member: recognized_member,
        cookied_payment_methods: params.to_unsafe_hash['payment_method_ids']
      ).process
    rescue ArgumentError => e
      @status = 400
      @status = 404 if e.to_s == 'PaymentProcessor::Exceptions::CustomerNotFound'
      render json: { error: e, success: false }, status: @status
    rescue StandardError => e
      render json: { error: e.message, success: false }, status: 500
    else
      render json: { success: true, follow_up_url: @follow_up_url }, status: 200
    end
  end

  def payment_methods
    tokens = (cookies.signed[:payment_methods] || '').split(',')
    render json: Payment::Braintree::PaymentMethod.where(token: tokens)
  end

  def webhook
    if client::WebhookHandler.handle(unsafe_params[:bt_signature], unsafe_params[:bt_payload])
      head :ok
    else
      head :not_found
    end
  end

  def refund
    @tracker = PaymentProcessor::Braintree::RefundTracker.new
    @tracker.sync
    render json: { refund_ids_synced: @tracker.unsynced_ids }, status: :ok
  end

  def one_click
    @result = client::OneClick.new(unsafe_params, cookies.signed[:payment_methods], member).run
    render status: :unprocessable_entity, errors: oneclick_payment_errors unless @result.success?
  end

  private

  def member
    if params[:user][:email].present?
      Member.find_by_email(params[:user][:email])
    elsif unsafe_params[:akid].present?
      Member.find_from_request(akid: unsafe_params[:akid], id: cookies.signed[:member_id])
    end
  end

  def oneclick_payment_errors
    if @result.class == Braintree::ErrorResult
      client::ErrorProcessing.new(@result, locale: locale).process
    else
      @result.errors
    end
  end

  def payment_options
    {
      nonce: params.require(:payment_method_nonce),
      amount: params.require(:amount).to_f,
      user: user_params,
      currency: params.require(:currency),
      page_id: params.require(:page_id),
      store_in_vault: store_in_vault?
    }.to_hash.tap do |options|
      options[:device_data] = unsafe_params[:device_data].to_json unless unsafe_params[:device_data].nil?

      options[:extra_params] = unsafe_params[:extra_action_fields] if unsafe_params[:extra_action_fields].present?

      if params[:source].present?
        options[:extra_params] ||= {}
        options[:extra_params][:source] = params[:source]
      end
    end
  end

  def client
    PaymentProcessor::Braintree
  end

  def page
    @page ||= Page.find(params.require(:page_id))
  end

  def recurring?
    @recurring ||= ActiveRecord::Type::Boolean.new.cast(unsafe_params[:recurring])
  end

  def user_params
    user_data = params
      .require(:user).permit!
      .merge(mobile_value)
      .to_hash
      .symbolize_keys
      .compact

    raise Api::Exceptions::InvalidParameters unless valid_user?(user_data)

    user_data
  end

  def valid_user?(user)
    user.slice(:email, :name, :country).all? { |_, value| value.present? }
  end

  def verify_bot
    action = 'donate/' + params[:page_id]
    @authorizer = PaymentRequestAuthorizer.new(recaptcha: params[:recaptcha_token],
                                               action: action, params: params, email: user_params[:email])
    unless @authorizer.valid?
      msg = @authorizer.errors.present? ? @authorizer.errors : 'Invalid request'
      render json: { success: false, message: msg }, status: :unprocessable_entity
      return false
    end
  end

  def member_matches_payload
    return false unless recognized_member.present?

    recognized_member.email == user_params[:email]
  end
end
