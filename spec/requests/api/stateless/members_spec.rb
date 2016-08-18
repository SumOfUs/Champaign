# frozen_string_literal: true
require 'rails_helper'

describe 'API::Stateless Members' do
  include Requests::RequestHelpers
  include AuthToken
  let!(:member) { create(:member, first_name: 'Harriet', last_name: 'Tubman', email: 'test@example.com') }
  let!(:other_member) { create(:member, first_name: 'Other', last_name: 'User', email: 'other_member@example.com')}

  before :each do
    member.create_authentication(password: 'password')
  end

  def auth_headers
    token = encode_jwt(member.token_payload)
    { authorization: "Bearer #{token}" }
  end

  describe 'GET show' do
    it 'returns member information for the member' do
      get "/api/stateless/members/#{member.id}", nil, auth_headers
      expect(response.status).to eq(200)
      expect(json_hash.keys).to include('id', 'first_name', 'last_name', 'email', 'country', 'city', 'postal', 'address1', 'address2')
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
    context 'with valid parameters' do

      let(:params) {{
        member: {
          first_name: "Harry",
          last_name: "Tubman",
          email: "test+1@example.com",
          country: "United Kingdom",
          city: "London",
          postal: "12345",
          address1: "Jam Factory 123"
        }
      }}

      subject do
        put "/api/stateless/members/#{member.id}", params, auth_headers
      end

      it 'updates the member locally' do
        subject
        expect(json_hash).to match({
                                     id: member.id,
                                     first_name:  params[:member][:first_name],
                                     last_name:  params[:member][:last_name],
                                     email:  params[:member][:email],
                                     country:  params[:member][:country],
                                     city:  params[:member][:city],
                                     postal:  params[:member][:postal],
                                     address1:  params[:member][:address1],
                                     address2:  params[:member][:address2]
                                   }.as_json)
      end

      it 'sends the message to the AK processor' do
        allow(ChampaignQueue).to receive(:push)
        expect(ChampaignQueue).to receive(:push).with({
          type: 'update_member',
          params: {
            email: params[:member][:email],
            first_name: params[:member][:first_name],
            last_name: params[:member][:last_name],
            country: params[:member][:country],
            city: params[:member][:city],
            postal: params[:member][:postal],
            address1: params[:member][:address1],
            address2: params[:member][:address2]
          }})
        subject
      end

    end

    context 'with invalid parameters' do
      let(:bad_params) {{
        member: {
          first_name: "Harry",
          last_name: "Tubman",
          email: other_member.email,
          country: "United Kingdom",
          city: "London",
          postal: "12345",
          address1: "a place"
        }
      }}

      it 'sends back error messages if the parameters are invalid' do
        put "/api/stateless/members/#{member.id}", bad_params, auth_headers
        expect(response.status).to be 422
        expect(response.success?).to be false
        expect(json_hash["errors"]).to match({
                                               "email" => [
                                                 "has already been taken"
                                               ]
                                             })
      end
    end
  end

end


