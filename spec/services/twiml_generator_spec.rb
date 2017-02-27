# frozen_string_literal: true

require 'rails_helper'

describe TwimlGenerator do
  subject { TwimlGenerator.run(call) }

  describe '.run' do
    context 'without sound clip' do
      let(:call) { create(:call) }

      it 'has Dial action attribute' do
        expect(subject).to match(%r{<Dial action=".*twilio/calls/#{call.id}/log.*"})
      end

      it 'has Dial number of target' do
        expect(subject).to match(%r{<Dial.*><Number>#{Regexp.quote(call.target_phone_number)}</Number></Dial>})
      end

      it 'includes extension if one is supplied' do
        allow(call).to receive(:target_phone_number).and_return('12345678ext234')
        re = %r{<Dial.*><Number sendDigits="234">12345678</Number></Dial>}
        expect(subject).to match re
      end

      it 'has no Play element' do
        expect(subject).not_to match(/Play/)
      end
    end

    context 'without sound clip' do
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
end
