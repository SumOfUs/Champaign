# frozen_string_literal: true

require 'rails_helper'

describe 'Api::Consent' do
  let!(:member) { create(:member, email: 'foo@example.com') }

  describe 'POST /api/stateless/members/:id/consent' do
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
end
