# frozen_string_literal: true

# == Schema Information
#
# Table name: form_elements
#
#  id            :integer          not null, primary key
#  form_id       :integer
#  label         :string
#  data_type     :string
#  default_value :string
#  required      :boolean
#  visible       :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  name          :string
#  position      :integer          default("0"), not null
#  choices       :jsonb            default("[]")
#  display_mode  :integer          default("0")
#

FactoryBot.define do
  factory :form_element do
    form
    label     { Faker::Lorem.word }
    name      { 'address1' }
    required  { false }
    data_type { 'text' }
    visible   { true }

    trait :email do
      label     { 'Email Address' }
      name      { 'email' }
      data_type { 'email' }
    end

    trait :phone do
      label     { 'Phone Number' }
      name      { 'phone' }
      data_type { 'phone' }
    end

    trait :country do
      label     { 'Country' }
      name      { 'country' }
      data_type { 'country' }
    end

    trait :postal do
      label     { 'Postal' }
      name      { 'postal' }
      data_type { 'postal' }
    end

    trait :paragraph do
      label     { 'Your thoughts' }
      name      { 'comment' }
      data_type { 'paragraph' }
    end

    trait :checkbox do
      label     { 'I agree' }
      name      { 'agrees' }
      data_type { 'checkbox' }
    end
  end
end
