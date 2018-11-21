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

class Plugins::DonationsThermometer < Plugins::Thermometer
  belongs_to :page, touch: true

  def current_total
    Money.from_amount(offset, Settings.default_currency) + total_donations
  end

  def current_progress
    total_donations / fundraising_goal * 100
  end

  def liquid_data(_supplemental_data = {})
    attributes.merge(
      percentage: current_progress,
      remaining: ActionController::Base.helpers.number_with_delimiter(fundraising_goal - current_total),
      total_donations: ActionController::Base.helpers.number_with_delimiter(current_total),
      goal_k: abbreviate_number(fundraising_goal)
    )
  end

  private

  def fundraising_goal
    if page.campaign.blank?
      page.fundraising_goal
    else
      page.campaign.fundraising_goal
    end
  end

  def total_donations
    if page.campaign.blank?
      page.total_donations
    else
      page.campaign.total_donations
    end
  end
end
