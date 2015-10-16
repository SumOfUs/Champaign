include ActionView::Helpers::NumberHelper

class Plugins::Thermometer < ActiveRecord::Base
  belongs_to :page

  DEFAULTS = { offset: 0, goal: 1000 }

  validates :goal, :offset, presence: true
  validates :goal, :offset, numericality: { greater_than_or_equal_to: 0 }

  def current_total
    offset + page.action_count
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

  def update_goal
    if goal_should_update
      self.goal = self.determine_next_goal
    end
  end

  protected
  def goal_should_update
    current_total >= self.goal
  end

  def determine_next_goal
    # We grow the goal by a number which keeps the target in close reach for a new signer.
    # For the purposes of this MVP, the new progress should be at 87.5%, rounded to the nearest 50.
    target_jump = 50
    increase_ratio = 1.125

    new_goal = current_total * increase_ratio
    goal_target_difference = new_goal % target_jump
    target_midpoint = target_jump * 0.5

    if goal_target_difference == 0
      new_goal
    elsif goal_target_difference <= target_midpoint
      new_goal - goal_target_difference
    else
      new_goal + target_jump - (goal_target_difference)
    end
  end
end
