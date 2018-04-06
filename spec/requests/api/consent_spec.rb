# frozen_string_literal: true

require 'rails_helper'

describe 'Api::Consent' do
  let!(:member) { create(:member, email: 'foo@example.com') }

  describe 'POST /api/consent' do
    context 'member exists' do
      it 'records time consent given' do
        now = Time.now.utc
        Timecop.freeze(now) do
          post '/api/consent', params: { email: 'foo@example.com', id: member.id }
          expect(member.reload.consented_at.to_s).to eq(now.to_s)
        end
      end
    end

    context 'member does not exist' do
      it 'returns not found' do
        post '/api/consent', params: { email: 'missing@example.com', id: 100 }

        expect(response.status).to eq(404)
      end
    end
  end
end
