# frozen_string_literal: true

class CallTool::Target
  include ActiveModel::Model
  extend HasPhoneNumber

  MAIN_ATTRS = %i[
    name
    title
    phone_number
    phone_extension
    country_name
    country_code
    caller_id
  ].freeze

  attr_accessor(*MAIN_ATTRS)
  attr_accessor :fields

  validate  :country_is_valid
  validates :phone_number, presence: true
  validates :name,         presence: true

  validate_phone_number :phone_number, :caller_id
  normalize_phone_number :phone_number, :caller_id

  def to_hash
    Hash[MAIN_ATTRS.collect { |attr| [attr, send(attr)] }].merge(fields: fields)
  end

  def country_name
    @country_name ||= ISO3166::Country[country_code]&.name
  end

  def country_name=(country_name)
    @country_name = country_name
    self.country_code = ISO3166::Country.find_country_by_name(country_name)&.alpha2
  end

  def ==(other)
    to_hash == other.to_hash
  end

  def id
    Digest::SHA1.hexdigest(to_hash.to_s)
  end

  private

  def country_is_valid
    if country_name.present? && country_code.blank?
      errors.add(:country, 'is invalid')
    end
  end
end
