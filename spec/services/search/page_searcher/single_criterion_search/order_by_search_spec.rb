# frozen_string_literal: true

require 'rails_helper'
require_relative '../page_searcher_spec_data.rb'

describe 'Search ::' do
  describe 'PageSearcher' do
    context 'searches by single criterion,' do
      context 'ordering' do
        include_context 'page_searcher_spec_data'
        let(:page_searcher) { Search::PageSearcher }

        it 'orders searches based on creation date' do
          expect(page_searcher.new(order_by: %i[created_at asc]).search).to eq(Page.all.order(created_at: :asc))
          expect(page_searcher.new(order_by: %i[created_at desc]).search).to eq(Page.all.order(created_at: :desc))
          expect(page_searcher.new(order_by: :created_at).search).to eq(Page.all.order(created_at: :asc))
        end
        it 'orders searches based on update date' do
          expect(page_searcher.new(order_by: %i[updated_at asc]).search).to eq(Page.all.order(updated_at: :asc))
          expect(page_searcher.new(order_by: %i[updated_at desc]).search).to eq(Page.all.order(updated_at: :desc))
          expect(page_searcher.new(order_by: :updated_at).search).to eq(Page.all.order(updated_at: :asc))
        end

        it 'orders searches based on title' do
          expect(page_searcher.new(order_by: %i[title asc]).search).to eq(Page.all.order(title: :asc))
          expect(page_searcher.new(order_by: %i[title desc]).search).to eq(Page.all.order(title: :desc))
          expect(page_searcher.new(order_by: :title).search).to eq(Page.all.order(title: :asc))
        end

        it 'orders searches based on featured' do
          expect(page_searcher.new(order_by: %i[featured asc]).search).to eq(Page.all.order(featured: :asc))
          expect(page_searcher.new(order_by: %i[featured desc]).search).to eq(Page.all.order(featured: :desc))
          expect(page_searcher.new(order_by: :featured).search).to eq(Page.all.order(featured: :asc))
        end

        it 'orders searches based on publish_status' do
          expect(page_searcher.new(order_by: %i[publish_status asc]).search.collect(&:publish_status))
            .to eq(Page.all.order(publish_status: :asc).collect(&:publish_status))

          expect(page_searcher.new(order_by: %i[publish_status desc]).search.collect(&:publish_status))
            .to eq(Page.all.order(publish_status: :desc).collect(&:publish_status))

          expect(page_searcher.new(order_by: :publish_status).search.collect(&:publish_status))
            .to eq(Page.all.order(publish_status: :asc).collect(&:publish_status))
        end

        it 'ignores invalid order_by_queries' do
          expect(page_searcher.new(order_by: %i[actions asc]).search).to eq(Page.all)
          expect(page_searcher.new(order_by: :actions).search).to eq(Page.all)
        end
      end
    end
  end
end
