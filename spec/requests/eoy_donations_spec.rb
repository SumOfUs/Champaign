# frozen_string_literal: true

require 'rails_helper'

describe 'eoy donation emails' do
  let(:member) { create :member, actionkit_user_id: '323423423999' }
  let(:ak_raw_id) { "#{Settings.action_kit.akid_secret}.2678.323423423999" }
  let(:ak_hash) { Base64.urlsafe_encode64(Digest::SHA256.digest(ak_raw_id))[0..5] }
  let(:akid) { "2678.323423423999.#{ak_hash}" }
  let(:valid_resp) {
    { body: '{"email": "' + member.email + '"}',
      status: 200, headers: { 'Content-Type' => 'application/json' } }
  }

  describe 'opt_out' do
    context 'valid data' do
      before do
        stub_request(:get, %r{#{Settings.ak_api_url}/user}).to_return(valid_resp)
        stub_request(:put, /#{Settings.ak_api_url}/).to_return(status: [204, 'No Content'])
        post '/eoy_donations/opt_out.json', params: { akid: akid, email: member.email }
      end

      it 'should opt out from eoy donation email' do
        msg = 'You’ve successfully opted out of our remaining fundraising emails in 2019. '
        msg += 'Thanks so much for your support, [FNAME]. If you’ve made this request in error, '
        msg += 'you can opt back into receiving our fundraising emails by clicking [HERE].'

        expect(json_hash).to include_json(
          success: true,
          msg: msg
        )
      end
    end

    context 'non matching email' do
      before do
        stub_request(:get, %r{#{Settings.ak_api_url}/user}).to_return(valid_resp)
        post '/eoy_donations/opt_out.json', params: { akid: akid, email: 'a@example.com' }
      end

      it 'should not opt out from eoy donation email' do
        expect(json_hash).to include_json(
          success: false,
          msg: 'Email does not match'
        )
      end
    end

    context 'invalid actionkit id' do
      before do
        stub_request(:get, %r{#{Settings.ak_api_url}/user}).to_return(status: [404, 'Not Found'])
        stub_request(:put, /#{Settings.ak_api_url}/).to_return(status: [204, 'No Content'])

        post '/eoy_donations/opt_out.json', params: { akid: '223.2342342.2423423', email: member.email }
      end

      it 'should not opt out from eoy donation email' do
        expect(json_hash).to include_json(
          success: false,
          msg: 'Email does not match'
        )
      end
    end

    context 'actionkit update error' do
      before do
        stub_request(:get, %r{#{Settings.ak_api_url}/user}).to_return(valid_resp)
        stub_request(:put, /#{Settings.ak_api_url}/).to_return(status: [500, 'Internal Server error'])
        post '/eoy_donations/opt_out.json', params: { akid: akid, email: member.email }
      end

      it 'should not opt out from eoy donation email' do
        msg = 'An error occurred while opting you out of the remaining fundraising emails'
        msg += ' in 2019. Click here to try again.'
        expect(json_hash).to include_json(
          success: false,
          msg: msg
        )
      end
    end
  end

  describe 'opt_in' do
    context 'valid data' do
      before do
        stub_request(:get, %r{#{Settings.ak_api_url}/user}).to_return(valid_resp)
        stub_request(:put, /#{Settings.ak_api_url}/).to_return(status: [204, 'No Content'])
        post '/eoy_donations/opt_in.json', params: { akid: akid, email: member.email }
      end

      it 'should opt out from eoy donation email' do
        expect(json_hash).to include_json(
          success: true,
          msg: 'You’ve successfully opted into receiving our remaining fundraising emails in 2019.'
        )
      end
    end

    context 'non matching email' do
      before do
        stub_request(:get, %r{#{Settings.ak_api_url}/user}).to_return(valid_resp)
        post '/eoy_donations/opt_in.json', params: { akid: akid, email: 'a@example.com' }
      end

      it 'should not opt out from eoy donation email' do
        expect(json_hash).to include_json(
          success: false,
          msg: 'Email does not match'
        )
      end
    end

    context 'invalid actionkit id' do
      before do
        stub_request(:get, %r{#{Settings.ak_api_url}/user}).to_return(status: [404, 'Not Found'])
        stub_request(:put, /#{Settings.ak_api_url}/).to_return(status: [204, 'No Content'])

        post '/eoy_donations/opt_in.json', params: { akid: '223.2342342.2423423', email: member.email }
      end

      it 'should not opt in from eoy donation email' do
        expect(json_hash).to include_json(
          success: false,
          msg: 'Email does not match'
        )
      end
    end

    context 'actionkit update error' do
      before do
        stub_request(:get, %r{#{Settings.ak_api_url}/user}).to_return(valid_resp)
        stub_request(:put, /#{Settings.ak_api_url}/).to_return(
          status: [500, 'Internal Server error']
        )
        post '/eoy_donations/opt_in.json', params: { akid: akid, email: member.email }
      end

      it 'should not opt in from eoy donation email' do
        msg = 'An error occurred while opting you into the remaining '
        msg += 'fundraising emails in 2019. Click here to try again.'
        expect(json_hash).to include_json(
          success: false,
          msg: msg
        )
      end
    end
  end
end
