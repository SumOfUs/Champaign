# frozen_string_literal: true

require 'rails_helper'

describe PageArchivesController, type: :routing do
  describe 'routing' do
    describe 'with /pages/:id/archive' do
      it 'routes to #create' do
        expect(post: '/pages/123/archive').to route_to('page_archives#create', page_id: '123')
      end

      it 'routes to #destroy' do
        expect(delete: '/pages/123/archive').to route_to('page_archives#destroy', page_id: '123')
      end
    end
  end
end
