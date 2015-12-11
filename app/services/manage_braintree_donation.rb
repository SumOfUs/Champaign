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
            card_num: @braintree_result.transaction.credit_card_details.last_4,
            exp_date_month: expire_month,
            exp_date_year: expire_year
        },
        user: {
            email: member.email,
            country: member.country
        }
    }.merge(@additional_values)
  end

  def expire_month
    split_expire_date[0]
  end

  def expire_year
    split_expire_date[1]
  end

  def split_expire_date
    @split_date ||= @braintree_result.transaction.credit_card_details.expiration_date.split('/')
  end
end
