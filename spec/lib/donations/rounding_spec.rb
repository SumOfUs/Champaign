require 'spec_helper'
require './lib/donations/donations'

describe Donations do

  describe 'round' do
    context 'floats under 20' do
      it 'rounds to the nearest integer' do
        cases = {
          10.1 => 10,
          3.03 => 3,
          6.51 => 7
        }

        cases.each do |value, expected|
          expect( Donations.round(value) ).to eq( expected )
        end
      end
    end

    context 'floats 20 and over' do
      it 'rounds to the nearest 5' do
        cases = {
          23.32 => 25,
          102.03 => 100,
          103.00 => 105
        }

        cases.each do |value, expected|
          expect( Donations.round(value) ).to eq( expected )
        end
      end
    end
  end
end

