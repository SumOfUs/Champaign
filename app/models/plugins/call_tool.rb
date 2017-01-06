# frozen_string_literal: true
# == Schema Information
#
# Table name: plugins_call_tools
#
#  id         :integer          not null, primary key
#  page_id    :integer
#  active     :boolean
#  ref        :string
#  form_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  title      :string
#  targets    :json             is an Array
#

class Plugins::CallTool < ActiveRecord::Base
  DEFAULTS = {}.freeze

  belongs_to :page, touch: true
  belongs_to :form

  has_attached_file :sound_clip, default_url: ''
  validates_attachment_content_type :sound_clip, content_type: %r{\Aaudio/.*\Z}, allow_nil: true

  validate :targets_are_valid

  def name
    self.class.name.demodulize
  end

  def liquid_data(_supplemental_data = {})
    {
      active: active,
      targets_by_country: targets_by_country,
      targets: json_targets,
      target_countries: target_countries,
      title: title
    }
  end

  def targets=(target_objects)
    write_attribute :targets, target_objects.map(&:to_hash)
  end

  def targets
    json_targets.map { |t| ::CallTool::Target.new(t) }
  end

  private

  # Temporary until fully targetting is implemented on front end
  def targets_by_country
    json_targets.group_by { |t| t['country_code'] }
  end

  def json_targets
    read_attribute(:targets)
  end

  # Returns [{ code: <country-code>, name: <country-name>}, {..} ...]
  def target_countries
    locale = page.language&.code || :en
    targets.map(&:country_code).uniq.map do |country_code|
      {
        name: ISO3166::Country[country_code].translation(locale),
        code: country_code
      }
    end
  end

  def targets_are_valid
    targets.each_with_index.each do |target, index|
      target.valid?
      target.errors.full_messages.each do |message|
        errors.add(:targets, "#{message} (row #{index + 1}")
      end
    end
  end
end
