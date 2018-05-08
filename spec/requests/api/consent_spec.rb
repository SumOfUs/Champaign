# frozen_string_literal: true

require 'rails_helper'

describe 'Api::Consent' do
  describe 'POST /api/stateless/members/:id/consent' do
    let!(:member) { create(:member, email: 'foo@example.com') }

    context 'given member exists that matches the passed id and email' do
      it 'updates the member' do
        post "/api/stateless/members/#{member.id}/consent", params: { email: 'foo@example.com' }
        expect(member.reload.consented).to be true
      end
    end

    context "given a member doesn't exist that matches the passed id and email" do
      it 'returns not found' do
        post "/api/stateless/members/#{member.id}/consent", params: { email: 'bar@example.com' }
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'DELETE /api/stateless/consent' do
    context 'member exists' do
      let!(:member) { create(:member, consented: true, email: 'foo@example.com') }

      it 'records time consent given' do
        delete "/api/stateless/consent?email=#{member.email}"
        expect(member.reload.consented).to be false
      end
    end

    context 'member does not exist' do
      it 'returns not found' do
        delete '/api/stateless/consent?email=bar@example.com'
        expect(response.status).to eq(404)
      end
    end

    context 'email is nil' do
      it 'returns not found' do
        delete '/api/stateless/consent'
        expect(response.status).to eq(404)
      end
    end
  end
end
