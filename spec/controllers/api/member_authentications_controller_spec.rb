# frozen_string_literal: true
require 'rails_helper'

describe Api::MemberAuthenticationsController do
  describe 'POST create' do
    let(:auth) { double('auth', valid?: true) }

    before do
      allow(MemberAuthenticationBuilder).to receive(:build) { auth }

      post :create, email: 'test@example.com', password: 'p', password_confirmation: 'p'
    end

    it 'builds authentication' do
      expect(MemberAuthenticationBuilder).to have_received(:build)
        .with(password: 'p', password_confirmation: 'p', email: 'test@example.com')
    end
  end
end
