# frozen_string_literal: true
require 'rails_helper'

describe CallCreator do
  let(:page) { create(:page, :with_call_tool) }
  let(:member) { create(:member) }

  context 'given valid params' do
    before do
      allow_any_instance_of(Twilio::REST::Calls).to receive(:create)
    end

    let(:params) do
      { page_id: page.id,
        member_id: member.id,
        member_phone_number: '12345678',
        target_index: 1 }
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
      expect(call.target_index).to eql(1)
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
        target_index: 1 }
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
end
