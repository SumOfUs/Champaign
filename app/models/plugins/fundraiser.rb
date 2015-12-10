class Plugins::Fundraiser < ActiveRecord::Base
  include Plugins::HasForm

  belongs_to :page
  belongs_to :donation_band

  DEFAULTS = { title: 'Donate now' }

  def liquid_data(supplemental_data={})
    bands = donation_band.present? ? donation_band.internationalize.to_json : "null"
    attributes.merge(form_liquid_data(supplemental_data)).merge(donation_bands: bands)
  end
end
