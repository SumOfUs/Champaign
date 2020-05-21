class PaymentRequestAuthorizer
  include ActiveModel::Validations

  MAX_TRANSACTIONS_WITHIN_20MINS = 2
  MAX_TRANSACTIONS_PER_DAY = 3
  VALID_DONATION_COUNT = 2
  VALID_ACTION_COUNT = 3

  attr_accessor :email, :recaptcha, :action, :params

  validates :email,     presence: true
  validates :recaptcha, presence: true
  validates :action,    presence: true

  def initialize(email:, recaptcha:, action:, params: {})
    @email = email.to_s.strip
    @recaptcha = recaptcha
    @action = action
    @params = params
  end

  def valid?
    super

    if errors.present?
      log_error_message('Recaptcha: VerificationInitiaizationFailed', true)
      return false
    end

    verify_recaptcha

    if valid_captcha?
      return true unless user.has_braintree_account?

      user_has_allowed_transaction_limit?
    else
      genuine_user?
    end
  end

  def genuine_user?
    unless user.has_account?
      return true if email_account_exist?(email)

      log_error_message('Recaptcha: Failed, UserAccountNotExist, EmailAccountExistence: false', true)
      return false
    end

    return true if user.has_valid_transactions_count?
    return true if user.has_valid_actions_count?

    msg = "Recaptcha: Failed, Donation Count < #{VALID_DONATION_COUNT}"
    msg += " and Action Count < #{VALID_ACTION_COUNT}"
    log_error_message(msg, true)

    false
  end

  # We are allowing 2 requests with in 20 mins.
  # we need to check whether the user has 1 record instead of 2
  # reason is we need to add current request in the calculation.
  def user_has_allowed_transaction_limit?
    return true unless user.has_braintree_account?

    if user.hourly_transaction_count >= MAX_TRANSACTIONS_WITHIN_20MINS
      log_error_message('Recaptcha: Success, HourlyLimit: Exceeds', true)
      return false
    end

    if user.daily_transaction_count >= MAX_TRANSACTIONS_PER_DAY
      log_error_message('Recaptcha: Success, DailyLimit: Exceeds', true)
      return false
    end
    true
  end

  def user
    @user ||= User.new(email)
  end

  def email_account_exist?(email)
    @email_verifier = EmailExistenceVerifier.new(email)
    return true if @email_verifier.exist?

    log_error_message("Recaptcha: Failed, Email: #{@email_verifier.errors.full_messages.to_sentence}")
    false
  end

  def verify_recaptcha
    @captcha = Recaptcha3.new(token: recaptcha, action: action)
    @valid_captcha = @captcha.human?
  end

  def valid_captcha?
    @valid_captcha
  end

  def log_error_message(code, transaction_rejected = false)
    msg = ''
    if transaction_rejected
      msg += 'Transaction rejected '
      errors.add(:base, 'Invalid request')
    end
    msg += "#{code}, email: #{email}"
    Rails.logger.info(msg)
  end

  class User
    attr_reader :braintree_account, :member_account, :email

    def initialize(email)
      @email = email.to_s.strip
    end

    # rubocop:disable Lint/DuplicateMethods
    def braintree_account
      @braintree_account ||= ::Payment::Braintree::Customer.find_by(email: email)
    end

    def member_account
      @member_account ||= Member.find_by(email: email)
    end
    # rubocop:enable Lint/DuplicateMethods

    def has_account?
      member_account.present?
    end

    def has_braintree_account?
      braintree_account.present?
    end

    def actions_count
      @actions_count ||= member_account.actions
        .where('created_at < ?', 3.days.ago)
        .order(created_at: :desc).limit(5).count
    end

    def transactions_count
      @transactions_count ||= braintree_account.transactions.count
    end

    def hourly_transaction_count
      braintree_account.transactions.where('created_at >= ? AND status = 0', 20.minutes.ago).count
    end

    def daily_transaction_count
      @daily_limit ||= braintree_account.transactions
        .where('created_at >= ? AND status = 0', Time.zone.now.beginning_of_day)
        .count
    end

    def has_valid_transactions_count?
      has_braintree_account? && transactions_count >= PaymentRequestAuthorizer::VALID_DONATION_COUNT
    end

    def has_valid_actions_count?
      member_account && actions_count >= PaymentRequestAuthorizer::VALID_ACTION_COUNT
    end
  end
end
