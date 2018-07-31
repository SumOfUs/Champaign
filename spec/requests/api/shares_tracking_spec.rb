# frozen_string_literal: true

require 'rails_helper'

describe 'tracking clicks and conversions on whatsapp shares' do
  let(:page) { create(:page, id: 123) }
  let(:button) { create(:share_button) }
  let!(:share) { create(:share_whatsapp, id: 1, conversion_count: 0, click_count: 0, page: page, button: button) }

  context 'tracking clicks - in api/shares/track' do
    it 'increments click count on the record' do
      expect(share.click_count).to eq 0
      post '/api/shares/track', params: { variant_id: 1, variant_type: 'whatsapp' }
      expect(share.reload.click_count).to eq 1
    end
  end

  describe 'tracking conversions - in pages/show' do
    it 'checks for share variant id and source and increments conversion count' do
      expect(share.conversion_count).to eq 0
      get '/pages/123', params: { variant_id: share.id, source: 'whatsapp' }
      expect(share.reload.conversion_count).to eq 1
    end

    it 'returns 200 even if variant ID in the parameters doesnt find a match' do
      get '/pages/123', params: { variant_id: 12_342, source: 'whatsapp' }
      expect(status).to eq 200
    end
  end
end
