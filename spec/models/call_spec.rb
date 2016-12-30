require 'rails_helper'

describe Call do
  let(:call) { build(:call) }
  describe 'member_phone_number validation' do
    it "must have at least 6 numbers" do
      call.member_phone_number = "+123"
      call.valid?
      expect(call.errors[:member_phone_number]).to include(/can only have/)
    end

    it "must include only valid characters" do
      call.member_phone_number = "+92161234*"
      call.valid?
      expect(call.errors[:member_phone_number]).to include(/can only have/)
    end

    it "allows valid phone numbers" do
      call.member_phone_number = "+54 (261) 123-12345"
      expect(call).to be_valid
    end
  end
end
