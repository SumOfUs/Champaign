# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id            :integer          not null, primary key
#  name          :string
#  actionkit_uri :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryGirl.define do
  factory :tag do
    name 'MyTag'
    actionkit_uri 'http://example.com/tag'
  end
end
