# frozen_string_literal: true

# == Schema Information
#
# Table name: share_emails
#
#  id         :integer          not null, primary key
#  body       :text
#  subject    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  button_id  :integer
#  page_id    :integer
#  sp_id      :string
#
# Indexes
#
#  index_share_emails_on_page_id  (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (page_id => pages.id)
#

require 'rails_helper'

describe Share::Email do
  describe 'validation' do
    subject { build(:share_email) }

    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'subject must be present' do
      subject.subject = nil
      expect(subject).to_not be_valid
    end

    it 'body must be present' do
      subject.body = nil
      expect(subject).to_not be_valid
    end

    it 'body must contain {LINK}' do
      subject.body = 'Foo'
      expect(subject).to_not be_valid
    end
  end

  describe 'share_progress?' do
    let(:email) { create(:share_email) }
    it 'is managed by ShareProgress' do
      expect(email.share_progress?).to eq true
    end
  end
end
