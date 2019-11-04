# frozen_string_literal: true

require 'rails_helper'

describe 'eoy donation emails' do
  let(:member) { create :member, actionkit_user_id: '323423423999' }
  let(:ak_raw_id) { "#{Settings.action_kit.akid_secret}.2678.323423423999" }
  let(:ak_hash) { Base64.urlsafe_encode64(Digest::SHA256.digest(ak_raw_id))[0..5] }
  let(:akid) { "2678.323423423999.#{ak_hash}" }

  context 'opt_out ' do
    before do
      stub_request(:any, /#{Settings.ak_api_url}/).to_return(status: [204, 'No Content'])
      get "/eoy_donations/opt_out?akid=#{akid}"
    end

    it 'should opt out from eoy donation email' do
      expect(flash[:notice]).to include('You have successfully opted out EOY donation email')
    end
  end

  context 'opt_in' do
    before do
      stub_request(:any, /#{Settings.ak_api_url}/).to_return(status: [204, 'No Content'])
      get "/eoy_donations/opt_in?akid=#{akid}"
    end

    it 'should opt in eoy donation email' do
      expect(flash[:notice]).to include('You have successfully opted in EOY donation email')
    end
  end

  context 'error' do
    before do
      get '/eoy_donations/opt_in?akid=2233.32423.23424'
    end

    it 'should raise error' do
      expect(flash[:alert]).to include('Error occured while opting in EOY donation email')
    end
  end

  context 'error updating action kit' do
    before do
      stub_request(:any, /#{Settings.ak_api_url}/).to_return(status: [404, 'Not Found'])
      get "/eoy_donations/opt_in?akid=#{akid}"
    end

    it 'should raise error' do
      expect(flash[:alert]).to include('Error occured while opting in EOY donation email')
    end
  end
end
