# frozen_string_literal: true

# == Schema Information
#
# Table name: uris
#
#  id         :integer          not null, primary key
#  domain     :string
#  path       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  page_id    :integer
#
# Indexes
#
#  index_uris_on_page_id  (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (page_id => pages.id)
#

FactoryBot.define do
  factory :uri do
    domain { 'google.com' }
    path { '/' }
    page_id { nil }
    association :page
  end
end
