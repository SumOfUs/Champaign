# frozen_string_literal: true
require 'rails_helper'

describe CallTool::Target do
  let(:target) { CallTool::Target.new }

  describe '#country_name=' do
    it 'assigns the country code if code is valid' do
      target.country_name = 'United states'
      expect(target.country_code).to eq 'US'
    end

    it 'sets country_code to nil if name is invalid' do
      target.country_name = 'Magic Country'
      expect(target.country_code).to be_nil
    end
  end

  describe '#country_name' do
    it 'returns the name of the country matching the country_code' do
      target.country_code = 'AR'
      expect(target.country_name).to eq('Argentina')
    end
  end

  describe 'country validation' do
    it 'is invalid if country name is wrong' do
      target.country_name = 'Magic country'
      expect(target).not_to be_valid
      expect(target.errors[:country]).to include('is invalid')
    end
  end

  describe 'caller_id=' do
    it 'normalizes the entered phone number' do
      target.caller_id = '+1 (234) 123456'
      expect(target.caller_id).to eq '1234123456'
    end
  end

  describe 'caller_id' do
    it "makes sure it's a valid phone number" do
      target.caller_id = '1234 4'
      target.valid?
      expect(target.errors[:caller_id]).to include('is an invalid number')
    end
  end
end
