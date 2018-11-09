# frozen_string_literal: true
# == Schema Information
#
# Table name: liquid_partials
#
#  id         :integer          not null, primary key
#  title      :string
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :liquid_partial do
    title { Faker::Company.bs }
    content "<div class='fun'>{{ title }}</div>"
  end
end
