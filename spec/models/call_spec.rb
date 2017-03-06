# frozen_string_literal: true
# == Schema Information
#
# Table name: calls
#
#  id                  :integer          not null, primary key
#  page_id             :integer
#  member_id           :integer
#  member_phone_number :string
#  created_at          :datetime
#  updated_at          :datetime
#  target_call_info    :jsonb            not null
#  member_call_events  :json             is an Array
#  twilio_error_code   :integer
#  target              :json
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

  describe '#target' do
    let(:call) { Call.new }
    let(:target) { build(:call_tool_target) }

    it 'returns nil if no target is set' do
      expect(call.target).to be_nil
    end

    it "returns the target if it's already set" do
      call.target = target
      expect(call.target.name).to eq target.name
      expect(call.target.phone_number).to eq target.phone_number
    end
  end

  describe '#target_id=' do
    let!(:page) { create(:page) }
    let!(:targets) { build_list(:call_tool_target, 3, :with_country) }
    let!(:call_tool) { create(:call_tool, page: page, targets: targets) }
    let(:call) { build(:call, page: page, target: nil) }

    it 'sets the target' do
      call.target_id = targets[1].id
      expect(call.target).to be == targets[1]
    end
  end
end
