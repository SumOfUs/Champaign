# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LiquidPartialsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/liquid_partials').to route_to('liquid_partials#index')
    end

    it 'routes to #new' do
      expect(get: '/liquid_partials/new').to route_to('liquid_partials#new')
    end

    it 'routes to #edit' do
      expect(get: '/liquid_partials/1/edit').to route_to('liquid_partials#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/liquid_partials').to route_to('liquid_partials#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/liquid_partials/1').to route_to('liquid_partials#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/liquid_partials/1').to route_to('liquid_partials#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/liquid_partials/1').to route_to('liquid_partials#destroy', id: '1')
    end
  end
end
