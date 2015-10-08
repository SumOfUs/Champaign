include ActionView::Helpers::NumberHelper

class Plugins::Thermometer < ActiveRecord::Base
  belongs_to :page

  DEFAULTS = { offset: 0, goal: 1000 }

  validates :goal, :offset, presence: true
  validates :goal, :offset, numericality: { greater_than_or_equal_to: 0 }

  def current_total
    offset + page.actions.count
  end

  def current_progress
    current_total / goal.to_f * 100
  end

  def liquid_data
    attributes.merge(
      percentage: current_progress,
      remaining: number_with_delimiter(goal - current_total),
      signatures: number_with_delimiter(current_total),
      goal_k: "#{(goal / 1000).to_i}k"
    )
  end

  def name
    self.class.name.demodulize
  end
end
