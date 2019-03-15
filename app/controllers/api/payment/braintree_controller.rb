# frozen_string_literal: true

class Api::Payment::BraintreeController < PaymentController
  skip_before_action :verify_authenticity_token, raise: false

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

  def one_click
    member = Member.find_by_email(params[:user][:email])
    @result = client::OneClick.new(unsafe_params, cookies.signed[:payment_methods], member).run
    unless @result.success?
      @errors = if @result.class == Braintree::ErrorResult
                  client::ErrorProcessing.new(@result, locale: locale).process
                else
                  @result.errors
                  # This is what gets rendered with the one_click.json.jbuilder template:
                  # json.success @result.success?
                  # unless @result.success?
                  #   json.params @result.params
                  #       {:transaction=>{:payment_method_nonce=>"fake-processor-declined-visa-nonce", :type=>"sale"}}
                  #   json.errors @result.errors
                  #       #<Braintree::Errors transaction:[(81502) Amount is required.], , >
                  #   json.message @result.message
                  #        "Amount is required."
                  # end
                end
      render status: :unprocessable_entity, errors: @errors
    end
  end

  private

  def payment_options
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
