class Plugins::Fundraiser < ActiveRecord::Base
  include Plugins::HasForm

  belongs_to :page
  belongs_to :donation_band

  DEFAULTS = { title: 'Donate now' }

  def liquid_data(supplemental_data={})
    donation_band_name = supplemental_data.has_key?(:url_params) ? supplemental_data[:url_params][:donation_band] : ''
    backup_id = donation_band.try(:id)
    bands = Donations::BandFinder.find_band(donation_band_name, backup_id)
    bands = bands.present? ? bands.internationalize.to_json : 'null'
    attributes.merge(form_liquid_data(supplemental_data)).merge(donation_bands: bands)
  end
end
