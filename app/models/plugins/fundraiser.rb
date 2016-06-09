class Plugins::Fundraiser < ActiveRecord::Base
  include Plugins::HasForm

  enum recurring_default: [:one_off, :recurring, :only_recurring]

  belongs_to :page, touch: true
  belongs_to :donation_band

  DEFAULTS = { title: 'fundraiser.donate_now' }

  def liquid_data(supplemental_data={})
    donation_band_name = supplemental_data[:donation_band]
    backup_id = donation_band.try(:id)
    bands = Donations::BandFinder.find_band(donation_band_name, backup_id)
    bands = bands.present? ? bands.internationalize : {}
    attributes.merge(form_liquid_data(supplemental_data)).merge(
      donation_bands: bands,
      recurring_default: recurring_default
    )
  end
end
