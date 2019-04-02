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

FactoryBot.define do
  factory :share_twitter, class: 'Share::Twitter' do
    sp_id { 1 }
    page { nil }
    title { 'MyString' }
    description { 'MyString {LINK}' }
    button_id { 1 }
  end
end
