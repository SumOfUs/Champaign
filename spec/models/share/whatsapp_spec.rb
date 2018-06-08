# frozen_string_literal: true

# == Schema Information
#
# Table name: share_whatsapps
#
#  id          :integer          not null, primary key
#  page_id     :integer
#  text        :string
#  button_id   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  click_count :integer
#  conversion_count :integer

require 'rails_helper'

describe Share::Whatsapp do
  describe 'validation' do
    subject { build(:share_whatsapp) }

    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'text must be present' do
      subject.text = nil
      expect(subject).to_not be_valid
    end

    it 'must have {LINK} in text' do
      subject.text = 'Foo'
      expect(subject).to_not be_valid
    end
  end

  describe 'share_progress?' do
    let(:whatsapp) { create(:share_whatsapp) }
    it 'is not managed by ShareProgress' do
      expect(whatsapp.share_progress?).to eq false
    end
  end
end
