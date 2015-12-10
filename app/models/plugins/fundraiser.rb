class Plugins::Fundraiser < ActiveRecord::Base
  include Plugins::HasForm

  belongs_to :page
  belongs_to :donation_band

  DEFAULTS = { title: 'Donate now' }

  def liquid_data(supplemental_data={})
    donation_band_name = ''
    backup_id = nil

    if supplemental_data.has_key? :url_params
      donation_band_name = supplemental_data[:url_params][:donation_band]
    end
    if donation_band.present?
      backup_id = donation_band.id
    end

    bands = Donations::BandFinder.find_band(donation_band_name, backup_id)

    if bands
      bands = bands.internationalize.to_json
    else
      bands = 'null'
    end
    attributes.merge(form_liquid_data(supplemental_data)).merge(donation_bands: bands)
  end
end
