# frozen_string_literal: true

require 'rails_helper'

describe PagesController, type: :routing do
  describe 'routing' do
    describe 'with /pages' do
      it 'routes to #index' do
        expect(get: '/pages').to route_to('pages#index')
      end

      it 'routes to #new' do
        expect(get: '/pages/new').to route_to('pages#new')
      end

      it 'routes to #edit' do
        expect(get: '/pages/my-slug/edit').to route_to('pages#edit', id: 'my-slug')
      end

      it 'routes to #follow_up' do
        expect(get: '/pages/my-slug/follow-up').to route_to('pages#follow_up', id: 'my-slug')
      end

      it 'routes to #show' do
        expect(get: '/pages/my-slug').to route_to('pages#show', id: 'my-slug')
      end

      it 'routes to #create' do
        expect(post: '/pages').to route_to('pages#create')
      end

      it 'routes to #update via PUT' do
        expect(put: '/pages/my-slug').to route_to('pages#update', id: 'my-slug')
      end

      it 'routes to #update via PATCH' do
        expect(patch: '/pages/my-slug').to route_to('pages#update', id: 'my-slug')
      end

      it 'routes to #destroy' do
        expect(delete: '/pages/my-slug').to route_to('pages#destroy', id: 'my-slug')
      end
    end

    describe 'with /a' do
      describe 'route helpers' do
        it 'routes to #edit' do
          expect(get: edit_member_facing_page_path('my-slug')).to route_to('pages#edit', id: 'my-slug')
        end

        it 'routes to #follow_up' do
          expect(get: follow_up_member_facing_page_path('my-slug')).to route_to('pages#follow_up', id: 'my-slug')
        end

        it 'routes to #show' do
          expect(get: member_facing_page_path('my-slug')).to route_to('pages#show', id: 'my-slug')
        end
      end

      it 'routes to #edit' do
        expect(get: '/a/my-slug/edit').to route_to('pages#edit', id: 'my-slug')
      end

      it 'routes to #follow_up' do
        expect(get: '/a/my-slug/follow-up').to route_to('pages#follow_up', id: 'my-slug')
      end

      it 'routes to #show' do
        expect(get: '/a/my-slug').to route_to('pages#show', id: 'my-slug')
      end

      it 'does not routes to #new' do
        expect(get: '/a/new').to route_to('pages#show', id: 'new')
      end

      it 'does not route to #index' do
        expect(get: '/a').to route_to('uris#show', path: 'a')
      end

      it 'does not route to #create' do
        expect(post: '/a').not_to be_routable
      end

      it 'does not route to #update via PUT' do
        expect(put: '/a/my-slug').not_to be_routable
      end

      it 'does not route to #update via PATCH' do
        expect(patch: '/a/my-slug').not_to be_routable
      end

      it 'does not route to #destroy' do
        expect(delete: '/a/my-slug').not_to be_routable
      end
    end
  end
end
