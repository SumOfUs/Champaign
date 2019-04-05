# frozen_string_literal: true

# == Schema Information
#
# Table name: share_whatsapps
#
#  id               :bigint(8)        not null, primary key
#  click_count      :integer          default(0), not null
#  conversion_count :integer          default(0), not null
#  text             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  button_id        :integer
#  page_id          :bigint(8)
#
# Indexes
#
#  index_share_whatsapps_on_page_id  (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (page_id => pages.id)
#

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

  describe 'html' do
    let(:button) { create(:share_button, share_button_html: '<div>{TEXT}</div>', url: 'example.com') }
    let(:whatsapp) { create(:share_whatsapp, button: button, text: 'Hello: {LINK}') }

    it 'constructs the share HTML from the encoded button URL, parameters and the text' do
      expect(whatsapp.html).to eq("<div>Hello%3A%20example.com%3Fsource%3Dwhatsapp%26variant_id%3D#{whatsapp.id}</div>")
    end
  end
end
