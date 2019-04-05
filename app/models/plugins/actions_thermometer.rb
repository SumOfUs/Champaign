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

class Plugins::ActionsThermometer < Plugins::Thermometer
  belongs_to :page, touch: true

  GOALS = [100, 200, 300, 400, 500,
           1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000,
           10_000, 15_000, 20_000, 25_000, 50_000, 75_000, 100_000,
           150_000, 200_000, 250_000, 300_000, 500_000, 750_000,
           1_000_000, 1_500_000, 2_000_000].freeze

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

  private

  def action_count
    @action_count ||= if page.campaign_id.present?
                        page.campaign.action_count
                      else
                        page.action_count
                      end
  end

  def next_goal_as_multiple_of(step)
    remainder = current_total % step
    current_total + step - remainder
  end
end
