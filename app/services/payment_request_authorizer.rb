class PaymentRequestAuthorizer
  include ActiveModel::Validations

  attr_accessor :email, :recaptcha, :action, :params

  validates :email,     presence: true
  validates :recaptcha, presence: true
  validates :action,    presence: true
  validate :verify_recaptcha
  validate :verify_user_donations, unless: :valid_captcha?

  def initialize(email:, recaptcha:, action:, params: {})
    @email = email.to_s.strip
    @recaptcha = recaptcha
    @action = action
    @params = params
  end

  def valid_captcha?
    @valid_captcha
  end

  def verify_recaptcha
    @captcha = Recaptcha3.new(token: recaptcha, action: action)
    @valid_captcha = @captcha.human?

    unless valid_captcha?
      msg = 'Transaction rejected [recaptcha failure] '
      msg += "- score: #{@captcha.score} - #{params}"
      Rails.logger.error(msg)

      return false
    end
    Rails.logger.info("Transaction recaptcha score: #{@captcha.score} - #{params}")
  end

  def verify_user_donations
    return false unless email.present?

    total_donations = begin
                        ::Payment::Braintree::Customer.find_by(email: email).transactions.count
                      rescue StandardError
                      end
    return true if total_donations >= 2

    errors.add(:base, 'Invalid request')
    # .valid? method returns false if we add the following line
    # in `verify_recaptcha` method.

    errors.add(:recaptcha, @captcha.errors) if @captcha.errors.present?
    msg = 'Transaction rejected: [insufficient donations] '
    msg += "user: #{email}'s past total donations: #{total_donations}"
    Rails.logger.info(msg)

    false
  end
end
