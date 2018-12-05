# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_fundraisers
#
#  id                :integer          not null, primary key
#  title             :string
#  ref               :string
#  page_id           :integer
#  active            :boolean          default("false")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  form_id           :integer
#  donation_band_id  :integer
#  recurring_default :integer          default("0"), not null
#  preselect_amount  :boolean          default("false")
#

class Plugins::Fundraiser < ApplicationRecord
  include Plugins::HasForm

  enum recurring_default: %i[one_off recurring only_recurring]

  belongs_to :page, touch: true
  belongs_to :donation_band

  # After creating a fundraiser plugin, also create a donations thermometer, unless one already exists for the page.
  after_create :create_donations_thermometer,
               unless: proc { |plugin| Plugins::DonationsThermometer.where(page_id: plugin.page.id).exists? }

  DEFAULTS = { title: 'fundraiser.donate_now' }.freeze

  def liquid_data(supplemental_data = {})
    donation_band_name = supplemental_data[:donation_band]
    backup_id = donation_band.try(:id)
    bands = Donations::BandFinder.find_band(donation_band_name, backup_id)
    bands = bands.present? ? bands.internationalize : {}
    attributes.merge(form_liquid_data(supplemental_data)).merge(
      donation_bands: bands,
      recurring_default: recurring_default
    )
  end

  def recurring?
    %w[recurring only_recurring].include?(recurring_default)
  end

  def self.donation_default_for_page(page_id)
    plugin = Plugins::Fundraiser.find_by(page_id: page_id)
    plugin ? plugin.recurring? : false
  end

  def create_donations_thermometer
    Plugins::DonationsThermometer.create!(page: page, active: false)
  end
end
