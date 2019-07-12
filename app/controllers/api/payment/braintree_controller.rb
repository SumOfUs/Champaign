# frozen_string_literal: true

class Api::Payment::BraintreeController < PaymentController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :check_api_key, only: [:refund]

  def token
    render json: { token: ::Braintree::ClientToken.generate }
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
    if params.dig(:user, :source).present?
      params[:extra_action_fields] ||= {}
      params[:extra_action_fields][:source] = ak_source
    end

    {
      nonce: unsafe_params[:payment_method_nonce],
      amount: unsafe_params[:amount].to_f,
      user: unsafe_params[:user].merge(mobile_value),
      currency: unsafe_params[:currency],
      page_id: unsafe_params[:page_id],
      store_in_vault: store_in_vault?
    }.tap do |options|
      options[:extra_params] = unsafe_params[:extra_action_fields] if unsafe_params[:extra_action_fields].present?
    end
  end

  def client
    PaymentProcessor::Braintree
  end

  def page
    @page ||= Page.find(unsafe_params[:page_id])
  end

  def recurring?
    @recurring ||= ActiveRecord::Type::Boolean.new.cast(unsafe_params[:recurring])
  end
end
