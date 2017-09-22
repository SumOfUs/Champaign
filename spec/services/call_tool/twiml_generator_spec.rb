# frozen_string_literal: true

require 'rails_helper'

describe CallTool::TwimlGenerator do
  describe 'Start' do
    let(:call) { create(:call) }
    subject { CallTool::TwimlGenerator::Start.run(call) }

    it 'has a Gather tag with an action matching the menu url' do
      expect(subject).to match(%r{<Gather.*action=.*/twilio/calls/#{call.id}/menu})
    end

    context 'with sound clip' do
      let(:sound_clip) { double(url: 'http://assets.com/foo-bar/1.wav') }

      before do
        allow(call).to receive(:sound_clip) { sound_clip }
      end

      it 'has Play attribute' do
        expect(subject).to match(%r{<Play>#{sound_clip.url}</Play>})
      end
    end
  end

  describe 'Menu' do
    subject { CallTool::TwimlGenerator::Menu.run(call, params) }
    let(:call) { create(:call) }
    let(:params) { {} }

    it 'has a Gather tag with an action matching the menu url' do
      expect(subject).to match(%r{<Gather.*action=.*/twilio/calls/#{call.id}/menu})
    end

    context 'without sound clip' do
      let(:page) { create(:page, :with_call_tool, language: create(:language, :french)) }
      let(:call) { create(:call, page: page) }

      it 'has a Say element' do
        expect(subject).to match(/<Say .* language="fr">/)
      end
    end

    context 'given the call has a menu soundclip' do
      let(:menu_sound_clip) { double(url: 'http://assets.com/foo-bar/menu.wav') }

      before do
        allow(call).to receive(:menu_sound_clip) { menu_sound_clip }
      end

      it 'has Play attribute' do
        expect(subject).to match(%r{<Play>#{menu_sound_clip.url}</Play>})
      end
    end

    context 'given the digit 1 is passed' do
      let(:params) { { 'Digits' => '1' } }
      it 'includes a Redirect tag pointing to the connect url' do
        expect(subject).to match(%r{<Redirect>.*/twilio/calls/#{call.id}/connect})
      end
    end

    context 'given the digit 2 is passed' do
      let(:params) { { 'Digits' => '2' } }
      it 'includes a Redirect tag pointing to the start url' do
        expect(subject).to match(%r{<Redirect>.*/twilio/calls/#{call.id}/start})
      end
    end
  end

  describe 'Connect' do
    let(:call) { create(:call) }
    subject { CallTool::TwimlGenerator::Connect.run(call) }

    it 'has a Dial tag with an action attribute pointing to the target_call_status url' do
      expect(subject).to match(%r{<Dial action=".*twilio/calls/#{call.id}/target_call_status.*"})
    end

    it 'has a Dial tag with the number of target' do
      expect(subject).to match(%r{<Dial.*><Number>#{Regexp.quote(call.target.phone_number)}</Number></Dial>})
    end

    context 'given the number has extensions' do
      let(:call) { create(:call, target: build(:call_tool_target, phone_number: '+12345678', phone_extension: '234')) }

      it 'includes the sendDigits option' do
        re = %r{<Dial.*><Number sendDigits="234">\+12345678</Number></Dial>}
        expect(subject).to match re
      end
    end
  end
end
