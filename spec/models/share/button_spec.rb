# frozen_string_literal: true

# == Schema Information
#
# Table name: share_buttons
#
#  id                :integer          not null, primary key
#  analytics         :text
#  share_button_html :string
#  share_type        :string
#  title             :string
#  url               :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  page_id           :integer
#  sp_id             :string
#
# Indexes
#
#  index_share_buttons_on_page_id  (page_id)
#

require 'rails_helper'

describe Share::Button do
  let(:button) { create :share_button }

  subject { button }

  it { is_expected.to be_valid }

  describe 'validation' do
    it 'is valid without a title' do
      button.title = nil
      expect(button).to be_valid
    end

    it 'is valid with a blank title' do
      button.title = ' '
      expect(button).to be_valid
    end

    it 'is invalid without a url' do
      button.url = nil
      expect(button).to be_invalid
    end

    it 'is invalid with a blank url' do
      button.url = ' '
      expect(button).to be_invalid
    end
  end

  describe '.share_progress?' do
    let(:facebook) { create :share_button, share_type: 'facebook' }
    let(:whatsapp) { create :share_button, share_type: 'whatsapp' }
    it 'returns true if the share type is managed by ShareProgress' do
      expect(facebook.share_progress?).to eq true
      expect(whatsapp.share_progress?).to eq false
    end
  end

  describe 'scopes' do
    describe 'share_progress' do
      let(:facebook) { create :share_button, share_type: 'facebook' }
      let(:whatsapp) { create :share_button, share_type: 'whatsapp' }
      let(:twitter) { create :share_button, share_type: 'twitter' }
      let(:email) { create :share_button, share_type: 'email' }
      it 'returns buttons types that are managed by ShareProgress' do
        expect(Share::Button.share_progress).to include(facebook, twitter, email)
        expect(Share::Button.share_progress).to_not include(whatsapp)
      end
    end
  end
end
