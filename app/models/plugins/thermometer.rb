class Plugins::Thermometer < ActiveRecord::Base
  belongs_to :campaign_page

  DEFAULTS = { offset: 0, goal: 1000 }

  validates :goal, :offset, presence: true
  validates :goal, :offset, numericality: true

  def get_current
    count = campaign_page.actions.count
    ( offset + count ) / goal * 100
  end

  def liquid_data
    attributes.merge('current' => get_current)
  end

  def name
    'Thermometer'
  end
end
