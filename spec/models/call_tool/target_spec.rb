# frozen_string_literal: true

require 'rails_helper'

describe CallTool::Target do
  let(:target) { build(:call_tool_target) }

  describe 'country validation' do
    it 'is valid if country_code matches country_name' do
      target.country_code = 'AR'
      target.country_name = 'Argentina'
      expect(target).to be_valid
    end

    it 'is invalid if country_name is blank' do
      target.country_code = 'AR'
      expect(target).not_to be_valid
      expect(target.errors[:country]).to include('is invalid')
    end

    it 'is invalid if country_code is blank' do
      target.country_name = 'Argentina'
      expect(target).not_to be_valid
      expect(target.errors[:country]).to include('is invalid')
    end

    it "is invalid if country_code doesn't match the country_name" do
      target.country_code = 'NLAND'
      target.country_name = 'United States'
      expect(target).not_to be_valid
      expect(target.errors[:country]).to include('is invalid')
    end
  end

  describe 'caller_id=' do
    it 'normalizes the entered phone number' do
      target.caller_id = '+1 (234) 123456'
      expect(target.caller_id).to eq '+1234123456'
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
