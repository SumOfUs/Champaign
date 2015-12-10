class Plugins::Fundraiser < ActiveRecord::Base
  include Plugins::HasForm

  belongs_to :page
  belongs_to :donation_band

  DEFAULTS = { title: 'Donate now' }

  def liquid_data(supplemental_data={})
    bands = Donations::BandFinder.find_band(supplemental_data[:url_params][:donation_band], donation_band.id)
    attributes.merge(form_liquid_data(supplemental_data)).merge(donation_bands: bands)
  end
end
