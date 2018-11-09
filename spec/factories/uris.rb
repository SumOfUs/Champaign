# frozen_string_literal: true
# == Schema Information
#
# Table name: uris
#
#  id         :integer          not null, primary key
#  domain     :string
#  path       :string
#  page_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :uri do
    domain 'google.com'
    path '/'
    page_id nil
    association :page
  end
end
