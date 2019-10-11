# frozen_string_literal: true

require 'rails_helper'

describe FacebookPixel do
  describe '.completed_registration_hash' do
    let(:page) { create(:page, id: 14, title: 'unleash-magnetic-schemas14') }
    let(:member) { create(:member, id: 3) }
    let(:action) { create(:action, page: page, member: member) }

    context 'page or action empty' do
      subject { FacebookPixel.completed_registration_hash(page: nil, action: nil) }
      it 'should return empty hash' do
        expect(subject.empty?).to be true
      end

      subject { FacebookPixel.completed_registration_hash(page: nil, action: action) }
      it 'should return empty hash' do
        expect(subject.empty?).to be true
      end

      subject { FacebookPixel.completed_registration_hash(page: page, action: nil) }
      it 'should return empty hash' do
        expect(subject.empty?).to be true
      end
    end

    context 'For new member with valid data' do
      before do
        action.instance_variable_set(:@member_created, true)
      end

      subject { FacebookPixel.completed_registration_hash(page: page, action: action) }
      it 'should return completed_registration_hash' do
        expect(subject).to match(
          content_name: 'unleash-magnetic-schemas14',
          currency: 'USD', page_id: 14, status: true,
          user_id: 3, value: 3
        )
      end
    end

    context 'For existing member with valid data' do
      before do
        action.instance_variable_set(:@member_created, false)
      end

      subject { FacebookPixel.completed_registration_hash(page: page, action: action) }
      it 'should return empty hash' do
        expect(subject).to match({})
      end
    end
  end
end
