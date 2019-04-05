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

require 'rails_helper'

RSpec.describe DonationBand, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
