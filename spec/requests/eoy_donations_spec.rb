# frozen_string_literal: true

require 'rails_helper'

describe 'eoy donation emails' do
  let(:member) { create :member }

  before do
    EoyDonationEmail.any_instance.stub(:sync_with_action_kit).and_return(true)
  end

  context 'opt_out ' do
    before do
      get "/eoy_donations/#{member.actionkit_user_id}/opt_out"
    end

    it 'should optout from eoy donation email' do
      expect(flash[:notice]).to include('You have successfully opted out EOY donation email')
    end
  end

  context 'opt_in' do
    before do
      get "/eoy_donations/#{member.actionkit_user_id}/opt_in"
    end

    it 'should opt in eoy donation email' do
      expect(response.body).to include('You have successfully opted in EOY donation email')
    end
  end
end
