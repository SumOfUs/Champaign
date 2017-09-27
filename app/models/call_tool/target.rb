# frozen_string_literal: true

class CallTool::Target < Target
  extend HasPhoneNumber

  set_attributes(
    :name,
    :title,
    :phone_number,
    :phone_extension,
    :country_name,
    :country_code,
    :caller_id
  )

  set_not_filterable_attributes(
    :phone_number,
    :phone_extension,
    :country_code,
    :caller_id
  )

  validate :country_is_valid
  validates :phone_number, presence: true
  validates :name,         presence: true

  validate_phone_number :phone_number, :caller_id
  normalize_phone_number :phone_number, :caller_id

  private

  def country_is_valid
    if (country_code.present? ^ country_name.present?) ||
       (country_code.present? && ISO3166::Country[country_code]&.name != country_name)
      errors.add(:country, I18n.t('validation.is_invalid'))
    end
  end
end
