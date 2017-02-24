# frozen_string_literal: true
# == Schema Information
#
# Table name: calls
#
#  id                  :integer          not null, primary key
#  page_id             :integer
#  member_id           :integer
#  member_phone_number :string
#  target_index        :integer
#  created_at          :datetime
#  updated_at          :datetime
#  log                 :jsonb            not null
#  member_call_events  :json             is an Array
#  twilio_error_code   :integer
#

require 'rails_helper'

describe Call do
  let(:call) { build(:call) }
  describe 'member_phone_number validation' do
    it 'must include only valid characters' do
      call.member_phone_number = '+92161234*'
      call.valid?
      expect(call.errors[:member_phone_number]).to include(/can only have/)
    end

    it 'must have at least 6 digits' do
      call.member_phone_number = '+923-'
      call.valid?
      expect(call.errors[:member_phone_number]).to include(/must have at least 6/)
    end

    it 'allows valid phone numbers' do
      call.member_phone_number = '+54 (261) 123-12345'
      expect(call).to be_valid
    end
  end
end
