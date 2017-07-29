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

  FILTERABLE = %i[
    name
    title
    country_name
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

  def country=(country)
    if ISO3166::Country[country].present?
      self.country_code = country
      self.country_name = ISO3166::Country[country].name
    elsif ISO3166::Country.find_country_by_name(country)
      self.country_code = ISO3166::Country.find_country_by_name(country)&.alpha2
      self.country_name = country
    end
  end

  def ==(other)
    to_hash == other.to_hash
  end

  def id
    Digest::SHA1.hexdigest(to_hash.to_s)
  end

  def keys
    MAIN_ATTRS.map(&:to_s).concat(fields&.keys || [])
  end

  private

  def country_is_valid
    if country_name.present? && country_code.blank?
      errors.add(:country, 'is invalid')
    end
  end
end
