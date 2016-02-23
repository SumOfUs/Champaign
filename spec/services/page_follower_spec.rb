require 'rails_helper'

describe PageFollower do
  include Rails.application.routes.url_helpers

  let(:page_id) { 1 }
  let(:follow_up_page_id) { 2 }
  let(:follow_up_layout_id) { 3 }

  describe "follow_up_path" do

    describe 'plan is :with_liquid' do

      let(:plan) { :with_liquid }

      describe 'while liquid_layout is blank' do
        it 'returns page path when page is passed' do
          result = PageFollower.new(plan, page_id, nil, follow_up_page_id).follow_up_path
          expect(result).to eq page_path(follow_up_page_id)
        end

        it 'returns nil when page is blank' do
          result = PageFollower.new(plan, page_id, nil, nil).follow_up_path
          expect(result).to eq nil
        end

      end

      describe 'while liquid_layout is passed' do
        it 'returns liquid_layout path when page is passed' do
          result = PageFollower.new(plan, page_id, follow_up_layout_id, follow_up_page_id).follow_up_path
          expect(result).to eq follow_up_page_path(page_id)
        end

        it 'returns liquid_layout path when page is blank' do
          result = PageFollower.new(plan, page_id, follow_up_layout_id, nil).follow_up_path
          expect(result).to eq follow_up_page_path(page_id)
        end

      end

    end

    describe 'plan is :with_page' do

      let(:plan) { :with_page }

      describe 'while page is blank' do
        it 'returns nil when liquid_layout is blank' do
          result = PageFollower.new(plan, page_id, nil, nil).follow_up_path
          expect(result).to eq nil
        end

        it 'returns liquid_layout path when liquid_layout is passed' do
          result = PageFollower.new(plan, page_id, follow_up_layout_id, nil).follow_up_path
          expect(result).to eq follow_up_page_path(page_id)
        end

      end

      describe 'while page is passed' do
        it 'returns page path when liquid_layout is passed' do
          result = PageFollower.new(plan, page_id, follow_up_layout_id, follow_up_page_id).follow_up_path
          expect(result).to eq page_path(follow_up_page_id)
        end

        it 'returns page path when liquid_layout is passed and plan is a string' do
          result = PageFollower.new(plan.to_s, page_id, follow_up_layout_id, follow_up_page_id).follow_up_path
          expect(result).to eq page_path(follow_up_page_id)
        end

        it 'returns page path when liquid_layout is blank' do
          result = PageFollower.new(plan, page_id, nil, follow_up_page_id).follow_up_path
          expect(result).to eq page_path(follow_up_page_id)
        end
      end
    end

    describe 'plan is anything else' do

      it 'raises error if plan is :with_link' do
        expect{
          PageFollower.new(nil, page_id, follow_up_layout_id, follow_up_page_id).follow_up_path
        }.to raise_error ArgumentError
      end

      it 'raises error if plan is blank' do
        expect{
          PageFollower.new(nil, page_id, follow_up_layout_id, follow_up_page_id).follow_up_path
        }.to raise_error ArgumentError
      end
    end
  end

  describe 'new_from_page' do

    let(:other_page) { instance_double('Page', slug: 'bleep-bloop')}
    let(:page) { instance_double('Page', follow_up_plan: 'with_liquid', slug: 'astro-droid', follow_up_liquid_layout_id: 3, follow_up_page: other_page) }

    it 'calls with page attributes' do
      allow(PageFollower).to receive(:new)
      PageFollower.new_from_page(page)
      expect(PageFollower).to have_received(:new).with('with_liquid', 'astro-droid', 3, 'bleep-bloop')
    end

    it 'returns the instance for call chaining' do
      expect(PageFollower.new_from_page(page).follow_up_path).to eq follow_up_page_path('astro-droid')
    end
  end

end
