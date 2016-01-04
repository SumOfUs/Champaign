class ManageBraintreeDonation
  include ActionBuilder

  def self.create(params:, braintree_result:, additional_values: {}, is_subscription: false)
    new(params: params, braintree_result: braintree_result, additional_values: additional_values, is_subscription: is_subscription).create
  end

  def initialize(params:, braintree_result:, additional_values: {}, is_subscription: false)
    @params = params
    @braintree_result = braintree_result
    @additional_values = additional_values
    @is_subscription = is_subscription
  end

  def create
    ChampaignQueue.push(queue_message)
    # We need a way to cross-reference this action at a later date to find out what page
    # with which we will associate ongoing donations, in the event this is a subscription.
    @params[:card_num] = card_num
    @params[:is_subscription] = @is_subscription
    @params[:amount] = transaction.amount
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
            amount: transaction.amount,
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

  def transaction
    return @transaction if @transaction

    # We don't use the `is_subscription` flag here because there are multiple ways that it's possible for
    # a subscription to be structured. That's more for future information retrieval, not for identifying the
    # internal structure of the braintree result we're searching through to manage notifications.
    if @braintree_result.transaction.present?
      # This is a one-off donation, so we can just use the built in transaction and send the data to the queue.
      @transaction = @braintree_result.transaction
    elsif @braintree_result.transactions.present?
      # This is a "start" subscription event, so we have an array of transactions. We can safely withdraw the most recent
      # transaction and use that information to send to the queue.
      @transaction = @braintree_result.transactions.last
    elsif @braintree_result.subscription.transactions.present?
      # This is an event which is notifying us that we're getting a transaction which is based on a recurring
      # donation being charged after the first event. Braintree will send us this data in webhook form. Like
      # with a subscription start event, we can grab the last transaction and run with it.
      @transaction = @braintree_result.subscription.transactions.last
    end
    @transaction
  end

  def card_num
    # At the moment, we only accept two forms of payment from Braintree: PayPal and Credit Card. If we don't have
    # Credit Card info along for the ride, we can safely assume at this time that it's a PayPal transaction and that's
    # what we do here.
    given_num = transaction.credit_card_details.last_4
    given_num.nil? ? 'PYPL' : given_num
  end

  def expire_month
    split_expire_date[0]
  end

  def expire_year
    split_expire_date[1]
  end

  def split_expire_date
    if transaction.credit_card_details.expiration_date == '/'
      # We weren't given an expiration, probably because it's a PayPal transaction, so set a fake expiration five years
      # in the future.
      [Time.now.month.to_s, (Time.now.year + 5).to_s]
    else
      @split_date ||= transaction.credit_card_details.expiration_date.split('/')
    end
  end
end
