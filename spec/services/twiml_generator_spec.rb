# frozen_string_literal: true

require 'rails_helper'

describe TwimlGenerator do
  describe 'StartCall' do
    subject { TwimlGenerator::StartCall.run(call) }

    context 'without sound clip' do
      let(:page) { create(:page, :with_call_tool, language: create(:language, :french)) }
      let(:call) { create(:call, page: page) }

      it 'has no Play element' do
        expect(subject).not_to match(/Play/)
      end

      it 'has a Say element' do
        expect(subject).to match(/<Say .* language="fr">/)
      end
    end

    context 'with sound clip' do
      let(:sound_clip) { double(url: 'foo-bar/1.wav') }
      let(:call) { create(:call) }

      before do
        allow(call).to receive(:sound_clip) { sound_clip }
      end

      it 'has Play attribute' do
        expect(subject).to match(%r{<Play>/foo-bar/1.wav</Play>})
      end
    end
  end

  describe 'ConnectCall' do
    let(:call) { create(:call) }
    subject { TwimlGenerator::ConnectCall.run(call) }

    it 'has Dial action attribute' do
      expect(subject).to match(%r{<Dial action=".*twilio/calls/#{call.id}/target_call_status.*"})
    end

    it 'has Dial number of target' do
      expect(subject).to match(%r{<Dial.*><Number>#{Regexp.quote(call.target_phone_number)}</Number></Dial>})
    end

    context 'given the number has extensions' do
      let(:call) { create(:call, target: build(:call_tool_target, phone_number: '12345678ext234')) }

      it 'includes the sendDigits option' do
        re = %r{<Dial.*><Number sendDigits="234">12345678</Number></Dial>}
        expect(subject).to match re
      end
    end
  end
end
