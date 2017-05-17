# frozen_string_literal: true
# == Schema Information
#
# Table name: plugins_thermometers
#
#  id         :integer          not null, primary key
#  title      :string
#  offset     :integer
#  page_id    :integer
#  active     :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  ref        :string
#

class Plugins::Thermometer < ApplicationRecord
  belongs_to :page, touch: true

  DEFAULTS = { offset: 0 }.freeze
  GOALS = [100, 200, 300, 400, 500,
           1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000,
           10_000, 15_000, 20_000, 25_000, 50_000, 75_000, 100_000,
           150_000, 200_000, 250_000, 300_000, 500_000, 750_000,
           1_000_000, 1_500_000, 2_000_000].freeze

  validates :offset, presence: true,
                     numericality: { greater_than_or_equal_to: 0 }
  after_initialize :set_defaults

  def current_total
    offset + action_count
  end

  def current_progress
    current_total / goal.to_f * 100
  end

  def goal
    GOALS.find { |goal| current_total < goal } || next_goal_as_multiple_of(1_000_000)
  end

  def liquid_data(_supplemental_data = {})
    attributes.merge(
      percentage: current_progress,
      remaining: ActionController::Base.helpers.number_with_delimiter(goal - current_total),
      signatures: ActionController::Base.helpers.number_with_delimiter(current_total),
      goal_k: abbreviate_number(goal)
    )
  end

  def name
    self.class.name.demodulize
  end

  private

  def action_count
    @action_count ||= if page.campaign_id.present?
                        Page.where(campaign_id: page.campaign_id).sum(:action_count)
                      else
                        page.action_count
                      end
  end

  def abbreviate_number(number)
    return number.to_s if number < 1000
    return "#{(goal / 1000).to_i}k" if number < 1_000_000
    locale = page.try(:language).try(:code)
    "%g #{I18n.t('thermometer.million', locale: locale)}" % (goal / 1_000_000.0).round(1)
  end

  def next_goal_as_multiple_of(step)
    remainder = current_total % step
    current_total + step - remainder
  end

  def set_defaults
    self.offset ||= DEFAULTS[:offset]
  end
end
