# frozen_string_literal: true

require 'rails_helper'

describe 'Api::Consent' do
  describe 'POST /api/stateless/members/:id/consent' do
    let!(:member) { create(:member, email: 'foo@example.com') }

    context 'member exists' do
      it 'records time consent given' do
        now = Time.now.utc
        Timecop.freeze(now) do
          post "/api/stateless/members/#{member.id}/consent", params: { email: 'foo@example.com' }
          expect(member.reload.consented_at.to_s).to eq(now.to_s)
        end
      end
    end

    context 'member does not exist' do
      it 'returns not found' do
        post "/api/stateless/members/#{member.id}/consent", params: { email: 'bar@example.com' }

        expect(response.status).to eq(404)
      end
    end
  end

  describe 'DELETE /api/stateless/consent' do
    context 'member exists' do
      let!(:member) { create(:member, consented_at: Time.now, email: 'foo@example.com') }

      it 'records time consent given' do
        delete "/api/stateless/consent?email=#{member.email}"
        expect(member.reload.consented_at).to be nil
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
