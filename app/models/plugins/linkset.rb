class Plugins::Linkset < ActiveRecord::Base
  belongs_to :campaign_page
  has_many :links, foreign_key: :plugins_linkset_id

  DEFAULTS = {}

  def liquid_data
    attributes.merge({ 'links' => links.map(&:attributes) })
  end

  def name
    'Linkset'
  end
end
