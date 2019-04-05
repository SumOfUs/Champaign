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

FactoryBot.define do
  factory :share_email, class: 'Share::Email' do
    subject { 'MyString' }
    body { 'MyText {LINK}' }
    page { nil }
    sp_id { '' }
    button_id { 1 }
  end
end
