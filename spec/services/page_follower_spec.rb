# frozen_string_literal: true
require 'rails_helper'

describe PageFollower do
  include Rails.application.routes.url_helpers

  let(:page_id) { 1 }
  let(:follow_up_page_id) { 2 }
  let(:follow_up_layout_id) { 3 }

  describe 'follow_up_path' do
    describe 'plan is :with_liquid' do
      let(:plan) { :with_liquid }

      describe 'while liquid_layout is blank' do
        it 'returns page path when page is passed' do
          result = PageFollower.new(plan, page_id, nil, follow_up_page_id).follow_up_path
          expect(result).to eq member_facing_page_path(follow_up_page_id)
        end

        it 'returns nil when page is blank' do
          result = PageFollower.new(plan, page_id, nil, nil).follow_up_path
          expect(result).to eq nil
        end
      end

      describe 'while liquid_layout is passed' do
        it 'returns liquid_layout path when page is passed' do
          result = PageFollower.new(plan, page_id, follow_up_layout_id, follow_up_page_id).follow_up_path
          expect(result).to eq follow_up_member_facing_page_path(page_id)
        end

        it 'returns liquid_layout path when page is blank' do
          result = PageFollower.new(plan, page_id, follow_up_layout_id, nil).follow_up_path
          expect(result).to eq follow_up_member_facing_page_path(page_id)
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
          expect(result).to eq follow_up_member_facing_page_path(page_id)
        end
      end

      describe 'while page is passed' do
        it 'returns page path when liquid_layout is passed' do
          result = PageFollower.new(plan, page_id, follow_up_layout_id, follow_up_page_id).follow_up_path
          expect(result).to eq member_facing_page_path(follow_up_page_id)
        end

        it 'returns page path when liquid_layout is passed and plan is a string' do
          result = PageFollower.new(plan.to_s, page_id, follow_up_layout_id, follow_up_page_id).follow_up_path
          expect(result).to eq member_facing_page_path(follow_up_page_id)
        end

        it 'returns page path when liquid_layout is blank' do
          result = PageFollower.new(plan, page_id, nil, follow_up_page_id).follow_up_path
          expect(result).to eq member_facing_page_path(follow_up_page_id)
        end
      end
    end

    describe 'extra params' do
      let(:plan) { :with_page }

      describe 'are not in URL if the extra_params parameter' do
        it 'is not passed' do
          result = PageFollower.new(plan, page_id, nil, follow_up_page_id).follow_up_path
          expect(result).to eq member_facing_page_path(follow_up_page_id)
        end

        it 'is nil' do
          result = PageFollower.new(plan, page_id, nil, follow_up_page_id, nil).follow_up_path
          expect(result).to eq member_facing_page_path(follow_up_page_id)
        end

        it 'is blank' do
          result = PageFollower.new(plan, page_id, nil, follow_up_page_id, ' ').follow_up_path
          expect(result).to eq member_facing_page_path(follow_up_page_id)
        end
      end

      describe 'when passed' do
        it 'ignores unknown parameters' do
          params = { herp: 'derp' }
          result = PageFollower.new(plan, page_id, nil, follow_up_page_id, params).follow_up_path
          expect(result).to eq member_facing_page_path(follow_up_page_id)
        end

        it 'passes bucket through' do
          params = { bucket: 'kick-it' }
          result = PageFollower.new(plan, page_id, nil, follow_up_page_id, params).follow_up_path
          expect(result).to eq member_facing_page_path(follow_up_page_id, bucket: 'kick-it')
        end

        it 'passes member_id through' do
          params = { member_id: 34 }
          result = PageFollower.new(plan, page_id, nil, follow_up_page_id, params).follow_up_path
          expect(result).to eq member_facing_page_path(follow_up_page_id, member_id: 34)
        end

        it 'passes member_id through and ignores unknown parameters' do
          params = { member_id: 34, foo: 'bar' }
          result = PageFollower.new(plan, page_id, nil, follow_up_page_id, params).follow_up_path
          expect(result).to eq member_facing_page_path(follow_up_page_id, member_id: 34)
        end

        it 'passes bucket and member_id through' do
          params = { bucket: 'kick-it', member_id: 45 }
          result = PageFollower.new(plan, page_id, nil, follow_up_page_id, params).follow_up_path
          expect(result).to eq member_facing_page_path(follow_up_page_id, member_id: 45, bucket: 'kick-it')
        end
      end
    end

    describe 'plan is anything else' do
      it 'raises error if plan is :with_link' do
        expect do
          PageFollower.new(nil, page_id, follow_up_layout_id, follow_up_page_id).follow_up_path
        end.to raise_error ArgumentError
      end

      it 'raises error if plan is blank' do
        expect do
          PageFollower.new(nil, page_id, follow_up_layout_id, follow_up_page_id).follow_up_path
        end.to raise_error ArgumentError
      end
    end
  end

  describe 'new_from_page' do
    let(:other_page) { instance_double('Page', slug: 'bleep-bloop') }
    let(:page) do
      instance_double(
        'Page',
        follow_up_plan: 'with_liquid',
        slug: 'astro-droid',
        follow_up_liquid_layout_id: 3,
        follow_up_page: other_page
      )
    end

    it 'calls with page attributes' do
      allow(PageFollower).to receive(:new)
      PageFollower.new_from_page(page)
      expect(PageFollower).to have_received(:new).with('with_liquid', 'astro-droid', 3, 'bleep-bloop', nil)
    end

    it 'returns the instance for call chaining' do
      expect(PageFollower.new_from_page(page).follow_up_path).to eq follow_up_member_facing_page_path('astro-droid')
    end
  end
end
