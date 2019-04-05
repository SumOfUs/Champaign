# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_thermometers
#
#  id         :integer          not null, primary key
#  active     :boolean          default(FALSE)
#  offset     :integer
#  ref        :string
#  title      :string
#  type       :string           default("ActionsThermometer"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  page_id    :integer
#
# Indexes
#
#  index_plugins_thermometers_on_page_id  (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (page_id => pages.id)
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
    format(
      '%<amount>g %<million>s',
      amount: (goal / 1_000_000.0).round(1),
      million: I18n.t('thermometer.million', locale: locale)
    )
  end
end
