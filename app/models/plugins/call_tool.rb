# frozen_string_literal: true
# == Schema Information
#
# Table name: plugins_call_tools
#
#  id                      :integer          not null, primary key
#  page_id                 :integer
#  active                  :boolean
#  ref                     :string
#  created_at              :datetime
#  updated_at              :datetime
#  title                   :string
#  targets                 :json             is an Array
#  sound_clip_file_name    :string
#  sound_clip_content_type :string
#  sound_clip_file_size    :integer
#  sound_clip_updated_at   :datetime
#  description             :text
#  target_by_country       :boolean          default(TRUE)
#

class Plugins::CallTool < ActiveRecord::Base
  DEFAULTS = {}.freeze

  belongs_to :page, touch: true
  belongs_to :form

  has_attached_file :sound_clip, default_url: ''
  validates_attachment_content_type :sound_clip, content_type: %r{\Aaudio/.*\Z}, allow_nil: true

  validate :targets_are_valid
  validate :target_countries_are_present, if: :target_by_country?

  def name
    self.class.name.demodulize
  end

  def liquid_data(_supplemental_data = {})
    {
      page_id: page_id,
      locale: page.language_code,
      active: active,
      targets: json_targets,
      target_by_country_enabled: target_by_country,
      countries: countries,
      countries_phone_codes: countries_phone_codes,
      title: title,
      description: description
    }
  end

  def targets=(target_objects)
    write_attribute :targets, target_objects.map(&:to_hash)
  end

  def targets
    json_targets.map { |t| ::CallTool::Target.new(t) }
  end

  private

  def json_targets
    read_attribute(:targets)
  end

  # Returns [{ code: <country-code>, name: <country-name>}, {..} ...]
  def countries
    list = if target_by_country
      targets.map(&:country_code).uniq.compact.map do |country_code|
        ISO3166::Country[country_code]
      end
    else
      ISO3166::Country.all
    end

    list.map do |country|
      {
        name: country.translation(page.language_code),
        code: country.alpha2,
        phoneCode: country.country_code.to_s
      }
    end
  end

  # Temporary ugly solution until we figure out if we want all countries here or
  # only a subset.
  def countries_phone_codes
    list = ISO3166::Country.all.reject do |country|
      country.country_code.blank?
    end

    list.map! do |country|
      {
        name: country.translation(page.language_code),
        code: country.country_code.to_s
      }
    end

    # Prioritize US
    us = list.find { |c| c[:name] == ISO3166::Country['US'].translation(page.language_code) }
    list.delete(us)
    list.unshift(us)
    list
  end

  def targets_are_valid
    targets.each_with_index.each do |target, index|
      target.valid?
      target.errors.full_messages.each do |message|
        errors.add(:targets, "#{message} (row #{index + 1})")
      end
    end
  end

  def target_countries_are_present
    targets.select { |t| t.country_code.blank? }.each_with_index do |_, index|
      errors.add(:targets, "Country can't be blank (row #{index + 1})")
    end
  end
end
