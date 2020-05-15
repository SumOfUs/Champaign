class EmailExistenceVerifier
  STATUS_VALID     = 'passed'.freeze
  STATUS_UNKNOWN   = 'unknown'.freeze
  EVENT_VALID      = 'mailbox_exists'.freeze
  EVENT_CATCH_ALL  = 'is_catchall'.freeze

  include ActiveModel::Validations
  attr_accessor :email
  attr_reader :resp

  validates :email, presence: true

  def initialize(email)
    @email = email
  end

  def data
    { key: Settings.bulk_email_checker.key, email: email }
  end

  def exist?
    return false unless valid?

    verify_email

    if resp.parsed_response.empty? || error.present?
      errors.add(:base, 'Unable to validate email')
      Rails.logger.info "Error occurred in Bulk Email verification: #{error}"
      return false
    end

    return true if valid_status? && valid_event?

    errors.add(:base, 'Invalid email / email account does not exist')
    false
  end

  def status
    return nil unless resp

    resp.parsed_response.dig('status').to_s.downcase
  end

  def event
    return nil unless resp

    resp.parsed_response.dig('event').to_s.downcase
  end

  def remaining_validations
    return 0 unless resp

    resp.parsed_response.dig('validationsRemaining').to_i
  end

  private

  def verify_email
    @resp ||= HTTParty.post(Settings.bulk_email_checker.end_point, body: data)
    # robocop:disable RuboCop::Cop::Lint::RescueException
  rescue StandardError => e
    Rails.logger.info "Error occurred in Bulk Email verification: #{e.message}"
    @resp = OpenStruct.new(parsed_response: {})
  end

  def error
    resp.parsed_response.dig('error')
  end

  def valid_status?
    [STATUS_VALID, STATUS_UNKNOWN].include?(status)
  end

  def valid_event?
    [EVENT_VALID, EVENT_CATCH_ALL].include?(event)
  end
end
