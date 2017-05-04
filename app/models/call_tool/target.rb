# frozen_string_literal: true
class CallTool::Target
  include ActiveModel::Model
  extend HasPhoneNumber

  attr_accessor :country_code,
                :phone_number,
                :phone_extension,
                :name,
                :title,
                :caller_id

  validate  :country_is_valid
  validates :phone_number, presence: true
  validates :name,         presence: true

  validate_phone_number :phone_number, :caller_id
  normalize_phone_number :phone_number, :caller_id

  def to_hash
    {
      country_code: country_code,
      phone_number: phone_number,
      phone_extension: phone_extension,
      name: name,
      title: title,
      caller_id: caller_id
    }
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
