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

  NOT_FILTERABLE = %i[
    phone_number
    phone_extension
    country_code
    caller_id
  ].freeze

  attr_accessor(*MAIN_ATTRS)
  attr_accessor :fields

  validate :country_is_valid
  validates :phone_number, presence: true
  validates :name,         presence: true

  validate_phone_number :phone_number, :caller_id
  normalize_phone_number :phone_number, :caller_id

  def to_hash
    Hash[MAIN_ATTRS.map { |attr| [attr, send(attr)] }].merge(fields: fields)
  end

  def ==(other)
    to_hash == other.to_hash
  end

  def id
    Digest::SHA1.hexdigest(to_hash.to_s)
  end

  def keys
    MAIN_ATTRS.map(&:to_s).select { |attr| send(attr).present? } + fields_keys
  end

  def get(key)
    if MAIN_ATTRS.include?(key.to_sym)
      send(key)
    else
      fields[key]
    end
  end

  private

  def fields_keys
    if fields.present?
      fields.select { |_k, v| v.present? }.keys
    else
      []
    end
  end

  def country_is_valid
    if (country_code.present? ^ country_name.present?) ||
       (country_code.present? && ISO3166::Country[country_code]&.name != country_name)
      errors.add(:country, I18n.t('validation.is_invalid'))
    end
  end
end
