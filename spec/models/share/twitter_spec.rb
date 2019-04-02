# frozen_string_literal: true

# == Schema Information
#
# Table name: share_twitters
#
#  id          :integer          not null, primary key
#  description :string
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  button_id   :integer
#  page_id     :integer
#  sp_id       :integer
#
# Indexes
#
#  index_share_twitters_on_page_id  (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (page_id => pages.id)
#

require 'rails_helper'

describe Share::Twitter do
  describe 'validation' do
    subject { build(:share_twitter) }

    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'description must be present' do
      subject.description = nil
      expect(subject).to_not be_valid
    end

    it 'must have {LINK} in description' do
      subject.description = 'Foo'
      expect(subject).to_not be_valid
    end
  end

  describe 'share_progress?' do
    let(:twitter) { create(:share_twitter) }
    it 'is managed by ShareProgress' do
      expect(twitter.share_progress?).to eq true
    end
  end
end
