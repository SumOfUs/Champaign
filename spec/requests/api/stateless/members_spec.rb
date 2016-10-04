# frozen_string_literal: true
require 'rails_helper'

describe 'API::Stateless Members' do
  include Requests::RequestHelpers
  include AuthToken

  describe 'GET show' do
    let(:member) do
      create(:member, first_name: 'Harriet',
                      last_name: 'Tubman',
                      email: 'test@example.com',
                      actionkit_user_id: '8244194')
    end

    let(:other_member) { create(:member, first_name: 'Other', last_name: 'User', email: 'other_member@example.com') }

    before :each do
      member.create_authentication(password: 'password')
    end

    def auth_headers
      token = encode_jwt(member.token_payload)
      { authorization: "Bearer #{token}" }
    end

    it 'returns member information for the member' do
      get "/api/stateless/members/#{member.id}", nil, auth_headers
      expect(response.status).to eq(200)
      expect(json_hash.keys).to include(
        'id',
        'first_name',
        'last_name',
        'email',
        'country',
        'city',
        'postal',
        'address1',
        'address2'
      )
      expect(json_hash).to match({
        id: member.id,
        first_name: member.first_name,
        last_name: member.last_name,
        email: member.email,
        country: member.country,
        city: member.city,
        postal: member.postal,
        address1: member.address1,
        address2: member.address2
      }.as_json)
    end
  end

  describe 'PUT update' do
    let(:member) do
      create(:member, first_name: 'Harriet',
                      last_name: 'Tubman',
                      email: 'test@example.com',
                      actionkit_user_id: '8244194')
    end

    let(:other_member) { create(:member, first_name: 'Other', last_name: 'User', email: 'other_member@example.com') }

    before :each do
      member.create_authentication(password: 'password')
    end

    def auth_headers
      token = encode_jwt(member.token_payload)
      { authorization: "Bearer #{token}" }
    end

    context 'with valid parameters' do
      let(:params) do
        {
          member: {
            first_name: 'Harry',
            last_name: 'Tubman',
            email: 'test+1@example.com',
            country: 'United Kingdom',
            city: 'London',
            postal: '12345',
            address1: 'Jam Factory 123'
          }
        }
      end

      subject do
        put "/api/stateless/members/#{member.id}", params, auth_headers
      end

      it 'updates the member locally and sends it back as json' do
        subject
        expect(json_hash).to match({
          id: member.id,
          first_name:  'Harry',
          last_name:  'Tubman',
          email:  'test+1@example.com',
          country:  'United Kingdom',
          city:  'London',
          postal:  '12345',
          address1: 'Jam Factory 123',
          address2: nil
        }.as_json)
      end

      it 'sends the message to the AK processor' do
        allow(ChampaignQueue).to receive(:push)

        expect(ChampaignQueue).to receive(:push).with(
          type: 'update_member',
          params: {
            akid: member.actionkit_user_id,
            email: 'test+1@example.com',
            first_name: 'Harry',
            last_name: 'Tubman',
            country: 'United Kingdom',
            city: 'London',
            postal: '12345',
            address1: 'Jam Factory 123',
            address2: nil
          }
        )
        subject
      end
    end

    context 'with invalid parameters' do
      let(:bad_params) do
        {
          member: {
            first_name: 'Harry',
            last_name: 'Tubman',
            email: other_member.email,
            country: 'United Kingdom',
            city: 'London',
            postal: '123456',
            address1: 'a place'
          }
        }
      end

      it 'sends back error messages if the parameters are invalid' do
        put "/api/stateless/members/#{member.id}", bad_params, auth_headers

        expect(response.status).to be 422

        expect(json_hash['errors']).to match('email' => [
          'has already been taken'
        ])
      end
    end
  end

  describe 'POST create' do
    let(:member_params) do
      {
        name: 'Bob',
        postal: 'W1',
        email: 'test@example.com',
        country: 'GB',
        password: 'password',
        password_confirmation: 'password'
      }
    end

    context 'valid request' do
      let(:member) { Member.first }

      it 'creates a member with authentication' do
        post api_stateless_members_path, member: member_params, format: :json

        expect(response.body).to eq(member.to_json)
        expect(member.authenticate('password')).to be_kind_of(MemberAuthentication)
      end
    end

    context 'invalid request' do
      it 'creates a member with authentication' do
        post api_stateless_members_path, member: member_params.except(:email), format: :json

        body = JSON.parse(response.body).deep_symbolize_keys
        expect(body).to eq(errors: { email: ["can't be blank"] })
      end
    end
  end
end
