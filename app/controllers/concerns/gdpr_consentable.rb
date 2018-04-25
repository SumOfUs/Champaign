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
    logger.info "GDPR enabled? #{ActiveRecord::Type::Boolean.new.deserialize(params[:gdpr_enabled])}"
    ActiveRecord::Type::Boolean.new.deserialize(params[:gdpr_enabled])
  end

  def consented?
    logger.info "Member consented? #{ActiveRecord::Type::Boolean.new.deserialize(params[:consented]) || false}"
    ActiveRecord::Type::Boolean.new.deserialize(params[:consented]) || false
  end

  def gdpr_applicable?
    logger.info "GDPR Applicable? #{gdpr_enabled? && Country[params[:country]]&.in_eu?}"
    gdpr_enabled? && Country[params[:country]]&.in_eu?
  end

  def set_consented_at
    logger.info 'GDPR Set consented at HIT'
    params[:consented_at] = Time.now if gdpr_applicable? && consented?
    logger.info params.to_s
  end
end
