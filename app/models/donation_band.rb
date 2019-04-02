# frozen_string_literal: true

# == Schema Information
#
# Table name: donation_bands
#
#  id         :integer          not null, primary key
#  amounts    :integer          default([]), is an Array
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DonationBand < ApplicationRecord
  has_paper_trail

  def internationalize
    converted = ::Donations::Currencies.for(amounts).to_hash
    converted.map { |k, vals| [k, ::Donations::Utils.round_and_dedup(vals)] }.to_h
  end
end
