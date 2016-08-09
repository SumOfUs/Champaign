# frozen_string_literal: true
# == Schema Information
#
# Table name: payment_braintree_customers
#
#  id                            :integer          not null, primary key
#  card_type                     :string
#  card_bin                      :string
#  cardholder_name               :string
#  card_debit                    :string
#  card_last_4                   :string
#  card_vault_token              :string
#  card_unique_number_identifier :string
#  email                         :string
#  first_name                    :string
#  last_name                     :string
#  customer_id                   :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  member_id                     :integer
#

FactoryGirl.define do
  factory :payment_braintree_customer, class: 'Payment::Braintree::Customer' do
    card_type { Faker::Business.credit_card_type }
    card_bin ''
    cardholder_name { Faker::Name.name }
    card_debit 'MyString'
    card_last_4 { Faker::Number.number(4) }
    card_unique_number_identifier { "cuni#{Faker::Number.number(6)}" }
    email { Faker::Internet.email }
    first_name 'MyString'
    last_name 'MyString'
    customer_id Faker::Number.number(6).to_s

    trait :with_payment_methods do
      # payment_methods is declared as a transient attribute and available in
      # attributes on the factory, as well as the callback via the evaluator
      transient do
        payment_methods 3
      end

      # the after(:create) yields two values; the user instance itself and the
      # evaluator, which stores all values from the factory, including transient
      after(:create) do |customer, evaluator|
        tokens = []
        evaluator.payment_methods.times do |i|
          tokens.push(
            token: Faker::Lorem.characters(i + 4),
            customer_id: customer.customer_id
          )
        end
      end
    end
  end
end
