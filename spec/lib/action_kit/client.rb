# frozen_string_literal: true

require 'rails_helper'

describe ActionKit::Client do
  describe '.configured?' do
    before :each do
      allow(Settings).to receive(:ak_api_url) { 'not blank' }
      allow(Settings).to receive(:ak_username) { 'not blank' }
      allow(Settings).to receive(:ak_password) { 'not blank' }
    end

    it 'returns true if ak_api_url, ak_password, and ak_username are all present' do
      expect(ActionKit::Client.configured?).to be true
    end

    it 'returns false if ak_api_url is blank' do
      allow(Settings).to receive(:ak_api_url) { nil }
      expect(ActionKit::Client.configured?).to be false
    end

    it 'returns false if ak_username is blank' do
      allow(Settings).to receive(:ak_username) { nil }
      expect(ActionKit::Client.configured?).to be false
    end

    it 'returns false if ak_password is blank' do
      allow(Settings).to receive(:ak_password) { nil }
      expect(ActionKit::Client.configured?).to be false
    end
  end
end
