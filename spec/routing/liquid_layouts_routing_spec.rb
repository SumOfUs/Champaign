# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LiquidLayoutsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/liquid_layouts').to route_to('liquid_layouts#index')
    end

    it 'routes to #new' do
      expect(get: '/liquid_layouts/new').to route_to('liquid_layouts#new')
    end

    it 'routes to #edit' do
      expect(get: '/liquid_layouts/1/edit').to route_to('liquid_layouts#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/liquid_layouts').to route_to('liquid_layouts#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/liquid_layouts/1').to route_to('liquid_layouts#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/liquid_layouts/1').to route_to('liquid_layouts#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/liquid_layouts/1').to route_to('liquid_layouts#destroy', id: '1')
    end
  end
end
