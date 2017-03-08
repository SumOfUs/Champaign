# frozen_string_literal: true
require 'rails_helper'

describe CallCreator do
  let(:page) { create(:page, :with_call_tool) }
  let(:target) { Plugins::CallTool.find_by_page_id(page.id).targets.sample }
  
  let(:member) { create(:member) }

  context 'given valid params' do
    before do
      allow_any_instance_of(Twilio::REST::Calls).to receive(:create)
    end

    let(:params) do
      { page_id: page.id,
        member_id: member.id,
        member_phone_number: '12345678',
        target_id: target.id }
    end

    it 'returns true' do
      expect(CallCreator.new(params).run).to be true
    end

    it 'creates a call' do
      expect { CallCreator.new(params).run }.to change(Call, :count).by(1)
      call = Call.last
      expect(call.page_id).to eql(page.id)
      expect(call.member_id).to eql(member.id)
      expect(call.member_phone_number).to eql('12345678')
    end

    it 'normalizes the phone number' do
      params[:member_phone_number] = '+46 0(70)27-86972'
      CallCreator.new(params).run
      call = Call.last
      # Removes the leading 0 and non-numeric chars
      expect(call.member_phone_number).to eql('46702786972')
    end

    it 'places the call' do
      expect_any_instance_of(Twilio::REST::Calls).to(
        receive(:create)
        .with(
          hash_including(from: Settings.calls.default_caller_id,
                         to: '12345678',
                         url: %r{twilio/calls/\d+/twiml})
        )
      )
      CallCreator.new(params).run
    end
  end

  context 'given invalid params' do
    let(:params) do
      { page_id: page.id,
        member_id: member.id,
        member_phone_number: 'wrong',
        target_id: target.id }
    end

    let(:service) { CallCreator.new(params) }

    it 'returns false' do
      expect(service.run).to be false
    end

    it 'returns a hash with error messages on #errors' do
      service.run
      expect(service.errors).to be_present
    end
  end

  context 'given twilio API responds with error' do
    before do
      allow_any_instance_of(Twilio::REST::Calls)
        .to receive(:create)
        .and_raise(Twilio::REST::RequestError.new('Error', 13_223))
    end

    let(:params) do
      { page_id: page.id,
        member_id: member.id,
        member_phone_number: '1234567',
        target_id: target.id }
    end

    it 'returns false' do
      expect(CallCreator.new(params).run).to be false
    end

    it 'stores the twilio error code on the call record' do
      CallCreator.new(params).run
      expect(Call.last.twilio_error_code).to eq(13_223)
    end
  end

  context 'given the target id is invalid' do
    let(:params) do
      { page_id: page.id,
        member_id: member.id,
        member_phone_number: '1234567',
        target_id: 'wrong' }
    end

    it 'returns false' do
      expect(CallCreator.new(params).run).to be false
    end

    it 'returns an appropriate error message' do
      service = CallCreator.new(params)
      service.run
      expect(service.errors[:base]).to include(/no longer available/)
    end
  end
end
