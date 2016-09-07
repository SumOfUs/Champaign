# frozen_string_literal: true
require 'rails_helper'

describe ActionKitController do
  let(:user) { double }

  before do
    allow(request.env['warden']).to receive(:authenticate!) { user }
    allow(ActionKit::Helper).to receive(:check_petition_name_is_available)
  end

  describe 'POST#check_slug' do
    it 'authenticates session' do
      expect(request.env['warden']).to receive(:authenticate!)

      post :check_slug, slug: 'foo-bar', format: :json
    end

    it 'checks if name is available' do
      expect(ActionKit::Helper)
        .to receive(:check_petition_name_is_available)
        .with('foo-bar')

      post :check_slug, slug: 'foo-bar', format: :json
    end
  end
end
