# frozen_string_literal: true

require 'rails_helper'

describe CallCreator do
  let(:page) { create(:page, :with_call_tool) }
  let!(:call_tool) { Plugins::CallTool.find_by_page_id(page.id) }
  let(:target) { Plugins::CallTool.find_by_page_id(page.id).targets.sample }
  let(:member) { create(:member) }
  let(:correct_checksum) { 'a1b2c3' }

  before :each do
    allow(Digest::SHA256).to receive(:hexdigest).and_return(correct_checksum)
  end

  shared_examples 'basic calling' do
    it 'returns true' do
      expect(CallCreator.new(params).run).to be true
    end

    it 'creates a call' do
      expect { CallCreator.new(params).run }.to change(Call, :count).by(1)
      call = Call.last
      expect(call.page_id).to eql(page.id)
      expect(call.member_id).to eql(member.id)
      expect(call.member_phone_number).to eql('13437003482')
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
          hash_including(from: call_tool.caller_phone_number.number,
                         to: '13437003482',
                         url: %r{twilio/calls/\d+/start},
                         status_callback: %r{twilio/calls/\d+/member_call_event})
        )
      )
      CallCreator.new(params).run
    end

    it 'publishes the event' do
      expect(CallEvent::New).to receive(:publish).with(an_instance_of(Call), an_instance_of(Hash))
      CallCreator.new(params).run
    end

    it 'creates an action' do
      CallCreator.new(params).run
      expect(Call.last.action).to be_an_instance_of(Action)
    end
  end

  context 'given valid params' do
    before do
      allow_any_instance_of(Twilio::REST::Calls).to receive(:create)
    end

    context 'with a valid manual target' do
      let(:params) do
        { page_id: page.id,
          member_id: member.id,
          member_phone_number: '+1 343-700-3482',
          target_phone_number: '+1 213-500-7319',
          target_name: 'Sen. Kevin de Leon',
          checksum: correct_checksum }
      end

      include_examples 'basic calling'

      it 'correctly populates the target fields' do
        CallCreator.new(params).run
        target = Call.last.target
        expect(target.name).to eq params[:target_name]
        expect(target.phone_number).to eq '12135007319'
      end
    end

    context 'with a target id' do
      let(:params) do
        { page_id: page.id,
          member_id: member.id,
          member_phone_number: '+1 343-700-3482',
          target_id: target.id }
      end

      include_examples 'basic calling'
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
        member_phone_number: '+1 343-700-3482',
        target_id: target.id }
    end

    it 'returns false' do
      expect(CallCreator.new(params).run).to be false
    end

    it 'stores the twilio error code on the call record' do
      CallCreator.new(params).run
      expect(Call.last.twilio_error_code).to eq(13_223)
    end

    it 'sets the status to failed' do
      CallCreator.new(params).run
      expect(Call.last.status).to eql('failed')
    end

    it 'doesnt create an action' do
      CallCreator.new(params).run
      expect(Call.last.action).to be_nil
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

  context 'given the manual targeting is invalid' do
    let(:invalid_params) do
      { page_id: page.id,
        member_id: member.id,
        member_phone_number: '+1 343-700-3482',
        target_phone_number: '+1 213-500-7319',
        target_name: 'Sen. Kevin de Leon',
        checksum: 'incorrect checksum' }
    end

    before :each do
      allow(CallTool::ChecksumValidator).to receive(:validate).and_return(false)
    end

    context 'and a valid target id is specified' do
      let(:params) { invalid_params.merge(target_id: target.id) }

      before do
        allow_any_instance_of(Twilio::REST::Calls).to receive(:create)
      end

      include_examples 'basic calling'
    end

    context 'and no target id is specified' do
      it 'returns false' do
        expect(CallCreator.new(invalid_params).run).to be false
      end

      it 'returns an appropriate error message' do
        service = CallCreator.new(invalid_params)
        service.run
        expect(service.errors[:base]).to include(/wasn't right about the number/)
      end
    end
  end
end
