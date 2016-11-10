# frozen_string_literal: true
# == Schema Information
#
# Table name: forms
#
#  id            :integer          not null, primary key
#  name          :string
#  description   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  visible       :boolean          default(FALSE)
#  master        :boolean          default(FALSE)
#  formable_id   :integer
#  formable_type :string
#  position      :integer          default(0), not null
#

FactoryGirl.define do
  factory :form do
    name { Faker::Name.name }
    description 'A description'
    master false

    factory :form_with_email do
      after(:create) do |form, _evaluator|
        create :form_element, form: form, name: 'email', label: 'Email', data_type: 'email'
      end
    end

    factory :form_with_email_and_optional_country do
      after(:create) do |form, _evaluator|
        create :form_element, form: form, name: 'email', label: 'Email', data_type: 'email', required: true
        create :form_element, form: form, name: 'country', label: 'Country', data_type: 'country', required: false
      end
    end

    factory :form_with_email_and_name do
      after(:create) do |form, _evaluator|
        create :form_element, form: form, name: 'email', label: 'Email', data_type: 'email', required: true
        create :form_element, form: form, name: 'name', label: 'Full name', data_type: 'text', required: true
      end
    end

    factory :form_with_phone_and_country do
      after(:create) do |form, _evaluator|
        create :form_element, form: form, name: 'country', label: 'Country', data_type: 'country', required: true
        create :form_element, form: form, name: 'phone', label: 'Phone number', data_type: 'phone', required: true
      end
    end

    factory :form_with_all_except_check do
      after :create do |form, _evaluator|
        create :form_element, form: form, name: 'email', label: 'Email', data_type: 'email', required: true
        create :form_element, form: form, name: 'name', label: 'Full name', data_type: 'text', required: true
        create :form_element, form: form, name: 'country', label: 'Country', data_type: 'country', required: true
        create :form_element, form: form, name: 'phone', label: 'Phone number', data_type: 'phone', required: true
      end
    end

    factory :form_with_name_email_and_country do
      after :create do |form, _evaluator|
        create :form_element, form: form, name: 'email', label: 'Email', data_type: 'email', required: true
        create :form_element, form: form, name: 'name', label: 'Full name', data_type: 'text', required: true
        create :form_element, form: form, name: 'country', label: 'Country', data_type: 'country', required: true
      end
    end

    factory :form_with_fields do
      after(:create) do |form, _evaluator|
        create_list(:form_element, 2, form: form)
      end
    end
  end
end
