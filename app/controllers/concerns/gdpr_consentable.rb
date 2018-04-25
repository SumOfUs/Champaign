module GDPRConsentable
  extend ActiveSupport::Concern

  included do
    before_action :set_consented_at, only: [:create]
  end

  def gdpr_consent_check_passed?
    return true unless gdpr_applicable?
    consented?
  end

  private

  def gdpr_enabled?
    ActiveRecord::Type::Boolean.new.deserialize(params[:gdpr_enabled])
  end

  def consented?
    ActiveRecord::Type::Boolean.new.deserialize(params[:consented]) || false
  end

  def gdpr_applicable?
    gdpr_enabled? && Country[params[:country]]&.in_eea?
  end

  def set_consented_at
    params[:consented_at] = Time.now.in_time_zone if gdpr_applicable? && consented?
  end
end
