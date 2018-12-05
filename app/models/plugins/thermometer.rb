# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_thermometers
#
#  id         :integer          not null, primary key
#  type       :string           not null
#  title      :string
#  offset     :integer
#  page_id    :integer
#  active     :boolean          default("false")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  ref        :string
#

class Plugins::Thermometer < ApplicationRecord
  def self.store_full_sti_class
    false
  end

  belongs_to :page, touch: true

  DEFAULTS = { offset: 0 }.freeze
  validates :offset, presence: true,
                     numericality: { greater_than_or_equal_to: 0 }
  after_initialize :set_defaults

  def name
    self.class.name.demodulize
  end

  private

  def set_defaults
    self.offset ||= DEFAULTS[:offset]
  end

  def abbreviate_number(number)
    return number.to_s if number < 1000
    return "#{(goal / 1000).to_i}k" if number < 1_000_000
    locale = page.try(:language).try(:code)
    "%g #{I18n.t('thermometer.million', locale: locale)}" % (goal / 1_000_000.0).round(1)
  end
end
