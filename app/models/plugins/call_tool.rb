# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_call_tools
#
#  id                            :integer          not null, primary key
#  page_id                       :integer
#  active                        :boolean
#  ref                           :string
#  created_at                    :datetime
#  updated_at                    :datetime
#  title                         :string
#  sound_clip_file_name          :string
#  sound_clip_content_type       :string
#  sound_clip_file_size          :integer
#  sound_clip_updated_at         :datetime
#  targets                       :json             default("{}"), is an Array
#  description                   :text
#  menu_sound_clip_file_name     :string
#  menu_sound_clip_content_type  :string
#  menu_sound_clip_file_size     :integer
#  menu_sound_clip_updated_at    :datetime
#  allow_manual_target_selection :boolean          default("false")
#  caller_phone_number_id        :integer
#  restricted_country_code       :string
#  target_by_attributes          :string           is an Array
#

class Plugins::CallTool < ApplicationRecord
  DEFAULTS = {}.freeze

  belongs_to :page, touch: true
  belongs_to :form
  belongs_to :caller_phone_number, class_name: 'PhoneNumber'

  has_attached_file :sound_clip, default_url: ''
  validates_attachment_content_type :sound_clip, content_type: %r{\Aaudio/.*\Z}, allow_nil: true

  has_attached_file :menu_sound_clip, default_url: ''
  validates_attachment_content_type :sound_clip, content_type: %r{\Aaudio/.*\Z}, allow_nil: true

  validate :targets_are_valid
  validate :restricted_country_code_is_valid

  def name
    self.class.name.demodulize
  end

  def liquid_data(_supplemental_data = {})
    Presenter.new(self).to_hash
  end

  def targets=(target_objects)
    write_attribute :targets, target_objects.map(&:to_hash)
  end

  def targets
    json_targets.map { |t| ::CallTool::Target.new(t) }
  end

  def target_keys
    discarded = %w[caller_id country_code name phone_number phone_extension title]
    targets
      .collect(&:keys)
      .flatten
      .uniq
      .reject { |k| discarded.include?(k) }
  end

  def find_target(id)
    targets.find { |t| t.id == id }
  end

  def restricted_country_code=(code)
    new_value = code.present? ? code : nil
    write_attribute(:restricted_country_code, new_value)
  end

  private

  def json_targets
    read_attribute(:targets)
  end

  def restricted_country_code_is_valid
    if restricted_country_code.present? && ISO3166::Country[restricted_country_code].blank?
      errors.add(:restricted_country_code, 'is invalid')
    end
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

  class Presenter
    attr_reader :obj
    def initialize(call_tool)
      @obj = call_tool
    end

    def to_hash
      {
        page_id: obj.page_id,
        locale: obj.page.language_code,
        active: obj.active,
        restricted_country_code: restricted_country_code,
        targets: targets,
        countries: countries,
        countries_phone_codes: countries_phone_codes,
        title: obj.title,
        description: obj.description,
        allow_manual_target_selection: obj.allow_manual_target_selection,
        target_by_attributes: obj.target_by_attributes
      }
    end

    private

    # TODO: guarantee present or nil on AR object
    def restricted_country_code
      if obj.restricted_country_code.blank?
        nil
      else
        obj.restricted_country_code
      end
    end

    def targets
      obj.targets.map { |t| t.to_hash.merge(id: t.id) }
    end

    # Returns [{ code: <country-code>, name: <country-name>}, {..} ...]
    def countries
      list =
        if obj.restricted_country_code.present?
          [ISO3166::Country[restricted_country_code]]
        else
          ISO3166::Country.all
        end

      list.map do |country|
        {
          name: country.translation(language_code),
          code: country.alpha2,
          phoneCode: country.country_code.to_s
        }
      end
    end

    def countries_phone_codes
      list = ISO3166::Country.all.reject do |country|
        country.country_code.blank?
      end

      list.map! do |country|
        {
          name: country.translation(language_code),
          code: country.country_code.to_s
        }
      end

      # Prioritize US
      us = list.find { |c| c[:name] == ISO3166::Country['US'].translation(language_code) }
      list.delete(us)
      list.unshift(us)
      list
    end

    def language_code
      obj.page.language_code
    end
  end
end
