class ManageBraintreeDonation
  include ActionBuilder

  def self.create(params:, braintree_result:, additional_values: {})
    new(params: params, braintree_result: braintree_result, additional_values: additional_values).create
  end

  def initialize(params:, braintree_result:, additional_values: {})
    @params = params
    @braintree_result = braintree_result
    @additional_values = additional_values
  end

  def create
    ChampaignQueue.push(queue_message)
    build_action
  end

  private
  def queue_message
    {
        type: 'donation',
        params: organize_params
    }
  end

  def organize_params
    {
        donationpage: {
            name: "#{page.slug}-donation",
            payment_account: 'Default Import Stub'
        },
        order: {
            amount: @braintree_result.transaction.amount,
            card_num: card_num,
            card_code: '007',
            exp_date_month: expire_month,
            exp_date_year: expire_year
        },
        user: {
            email: member.email,
            country: member.country
        }
    }.merge(@additional_values)
  end

  def card_num
    # At the moment, we only accept two forms of payment from Braintree: PayPal and Credit Card. If we don't have
    # Credit Card info along for the ride, we can safely assume at this time that it's a PayPal transaction and that's
    # what we do here.
    given_num = @braintree_result.transaction.credit_card_details.last_4
    given_num.nil? ? 'PYPL' : given_num
  end

  def expire_month
    split_expire_date[0]
  end

  def expire_year
    split_expire_date[1]
  end

  def split_expire_date
    p @braintree_result.transaction.credit_card_details
    if @braintree_result.transaction.credit_card_details.expiration_date == '/'
      # We weren't given an expiration, probably because it's a PayPal transaction, so set a fake expiration five years
      # in the future.
      p 'here'
      [Time.now.month, Time.now.year + 5]
    else
      p 'there'
      @split_date ||= @braintree_result.transaction.credit_card_details.expiration_date.split('/')
    end

  end
end
