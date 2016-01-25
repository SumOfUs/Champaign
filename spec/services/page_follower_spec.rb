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

end
