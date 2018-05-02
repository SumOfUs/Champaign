module Consentable
  extend ActiveSupport::Concern

  included do
    before_action :set_consented_at, only: [:create]
  end

  def consent_check_passed?
    return true unless consent_applicable?
    consented?
  end

  private

  def consent_enabled?
    ActiveRecord::Type::Boolean.new.deserialize(params[:consent_enabled])
  end

  def consented?
    ActiveRecord::Type::Boolean.new.deserialize(params[:consented]) || false
  end

  def consent_applicable?
    consent_enabled? && Country[params[:country]]&.in_eea?
  end

  def set_consented_at
    params[:consented_at] = Time.now.in_time_zone if consent_applicable? && consented?
  end
end
