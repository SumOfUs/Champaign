# frozen_string_literal: true
require 'rails_helper'

describe Api::ActionsController do
  describe 'routing' do
    it 'routes to POST#validate' do
      expect(post: '/api/pages/1/actions/validate').to route_to(
        controller: 'api/actions',
        action: 'validate',
        page_id: '1'
      )
    end

    it 'routes to POST#create' do
      expect(post: '/api/pages/1/actions').to route_to(
        controller: 'api/actions',
        action: 'create',
        page_id: '1'
      )
    end

    it 'does not route to GET#create' do
      expect(get: '/api/pages/1/actions').to route_to(
        controller: 'uris',
        action: 'show',
        path: 'api/pages/1/actions'
      )
    end
  end
end
