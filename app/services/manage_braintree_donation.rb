# frozen_string_literal: true

class ManageBraintreeDonation
  PAYPAL_IDENTIFIER = 'PYPL'

  def self.create(params:, braintree_result:, is_subscription: false, store_in_vault: false)
    new(
      params: params,
      braintree_result: braintree_result,
      is_subscription: is_subscription,
      store_in_vault: store_in_vault
    ).create
  end

  def initialize(params:, extra_params: {}, braintree_result:, is_subscription: false, store_in_vault: false)
    @params = params
    @extra_params = extra_params.clone
    @braintree_result = braintree_result
    @is_subscription = is_subscription
    @store_in_vault = store_in_vault
  end

  def create
    # We need a way to cross-reference this action at a later date to find out what page
    # with which we will associate ongoing donations, in the event this is a subscription.
    @params.merge!(
      {
        amount: transaction.amount.to_s,
        card_num: card_num,
        currency: transaction.currency_iso_code,
        transaction_id: transaction.id,
        subscription_id: subscription_id,
        is_subscription: @is_subscription,
        card_expiration_date: transaction.credit_card_details.expiration_date,
        payment_provider: 'braintree',
        action_express_donation: 0,
        store_in_vault: @store_in_vault
      }.tap do |params|
        params[:recurrence_number] = 0   if @is_subscription
        params[:source] = request_source if request_source.present?
      end
    )
    ManageAction.create(@params, extra_params: { donation: true }.merge(@extra_params))
  end

  private

  def page
    @page ||= Page.find(@params[:page_id])
  end

  def akit_donation_page_id
    page.ak_donation_resource_uri.to_s.gsub(%r{/$}, '').split('/').last
  end

  def request_source
    return nil unless akit_donation_page_id.present?

    page.donation_followup? ? "post-action-#{akit_donation_page_id}-#{original_source}" : nil
  end

  def original_source
    # By default AK takes website if source parameter is empty
    @params.fetch(:source, 'website')
  end

  def transaction
    @transaction ||= @braintree_result.transaction || @braintree_result.subscription.transactions.try(:last)
  end

  def subscription_id
    @braintree_result.subscription.try(:id)
  end

  def card_num
    is_paypal? ? PAYPAL_IDENTIFIER : transaction.credit_card_details.last_4
  end

  def is_paypal?
    transaction.payment_instrument_type.inquiry.paypal_account?
  end
end
