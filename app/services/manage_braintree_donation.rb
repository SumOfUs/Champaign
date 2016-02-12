class ManageBraintreeDonation
  include ActionBuilder
  PAYPAL_IDENTIFIER = 'PYPL'

  def self.create(params:, braintree_result:, is_subscription: false)
    new(params: params, braintree_result: braintree_result, is_subscription: is_subscription).create
  end

  def initialize(params:, braintree_result:, is_subscription: false)
    @params = params
    @braintree_result = braintree_result
    @is_subscription = is_subscription
  end

  def create
    ChampaignQueue.push(queue_message)

    # We need a way to cross-reference this action at a later date to find out what page
    # with which we will associate ongoing donations, in the event this is a subscription.
    @params[:card_num] = card_num
    @params[:is_subscription] = @is_subscription
    @params[:amount] = transaction.amount
    @params[:currency] = transaction.currency_iso_code
    @params[:transaction_id] = transaction.id
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
        name:             "#{page.slug}-donation",
        payment_account:  get_payment_account
      },
      order: {
        amount:         transaction.amount.to_s,
        card_num:       card_num,
        card_code:      '007',
        exp_date_month: expire_month,
        exp_date_year:  expire_year,
        currency:       transaction.currency_iso_code
      },
      action: {
        source:         @params[:source] # falls back to nil
      },
      user: user_params
    }
  end

  def user_params
    form_data = @params.select{ |k, v| !k.to_s.match(/(page_id|form_id|name|full_name)/) }
    form_data.symbolize_keys.merge(
      first_name: member.first_name,
      last_name:  member.last_name,
      email:    member.email,
      country:  member.country
    )
  end

  # ActionKit can accept one of the following:
  #
  # PayPal USD
  # PayPal GBP
  # PayPal CAD
  # PayPal EUR
  # PayPal AUD
  #
  # Braintree USD
  # Braintree CAD
  # Braintree AUD
  # Braintree GBP
  # Braintree EUR
  #
  def get_payment_account
    provider = is_paypal? ? 'PayPal' : 'Braintree'
    "#{provider} #{transaction.currency_iso_code}"
  end

  def transaction
    return @transaction if @transaction

    if @braintree_result.transaction.present?
      # This is a one-off donation, so we can just use the built in transaction and send the data to the queue.
      @transaction = @braintree_result.transaction
    elsif @braintree_result.subscription.transactions.present?
      @transaction = @braintree_result.subscription.transactions.last
    end
    @transaction
  end

  def card_num
    is_paypal? ? PAYPAL_IDENTIFIER : transaction.credit_card_details.last_4
  end

  def is_paypal?
    transaction.payment_instrument_type == "paypal_account"
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
