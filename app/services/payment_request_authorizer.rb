class PaymentRequestAuthorizer
  include ActiveModel::Validations

  MAX_TRANSACTIONS_WITHIN_20MINS = 2
  MAX_TRANSACTIONS_PER_DAY = 3

  attr_accessor :email, :recaptcha, :action, :params

  validates :email,     presence: true
  validates :recaptcha, presence: true
  validates :action,    presence: true

  validate :verify_recaptcha
  validate :verify_customer_transaction_limit, if: :valid_captcha?
  validate :verify_user_donations, unless: :valid_captcha?

  def initialize(email:, recaptcha:, action:, params: {})
    @email = email.to_s.strip
    @recaptcha = recaptcha
    @action = action
    @params = params
  end

  def verify_recaptcha
    return false if errors.present?

    validate_recaptcha

    unless valid_captcha?
      msg = "[recaptcha failure] - score: #{@captcha.score} - #{params}"
      Rails.logger.error(msg)

      # New customer must not have failed recaptcha
      if new_customer?
        errors.add(:base, 'Invalid request')
        errors.add(:recaptcha, @captcha.errors) if @captcha.errors.present?
        return false
      end
    end
    Rails.logger.info("Transaction recaptcha score: #{@captcha.score} - #{params}")
    true
  end

  def validate_recaptcha
    @captcha = Recaptcha3.new(token: recaptcha, action: action)
    @valid_captcha = @captcha.human?
  end

  def valid_captcha?
    @valid_captcha
  end

  def new_customer?
    customer.nil?
  end

  def customer
    @customer ||= ::Payment::Braintree::Customer.find_by(email: email)
  end

  def total_donations
    @total_donations ||= customer.transactions.count
  end

  def verify_user_donations
    return false if errors.present?

    if customer.nil?
      errors.add(:base, 'Invalid request')
      return false
    end

    return true if total_donations >= 2

    errors.add(:base, 'Invalid request')
    msg = 'Transaction rejected: [Recaptcha failed and insufficient donations] '
    msg += "user: #{email}'s past total donations: #{total_donations}"
    Rails.logger.info(msg)
    false
  end

  def verify_customer_transaction_limit
    return false if errors.present?

    # no need to check transactions for new user
    return true if new_customer?

    return false unless valid_transaction_count?(
      20.minutes.ago,
      MAX_TRANSACTIONS_WITHIN_20MINS,
      '20Minutes'
    )
    return false unless valid_transaction_count?(
      Time.zone.now.beginning_of_day,
      MAX_TRANSACTIONS_PER_DAY,
      'Daily'
    )

    true
  end

  def valid_transaction_count?(time, limit, msg = '')
    # Allow second transaction if there is already only one existing
    return true if total_transactions_on_last(time) < limit

    msg = "Transaction rejected: [RecaptchaSuccess and Transaction#{msg}LimitExceeded] for customer: #{email}"
    Rails.logger.info(msg)
    errors.add(:base, 'Invalid request')
    false
  end

  def total_transactions_on_last(time)
    customer.transactions.where('created_at >= ? AND status = 0', time).count
  end
end
