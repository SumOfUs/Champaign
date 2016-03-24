FactoryGirl.define do
  factory :payment_braintree_customer, :class => 'Payment::BraintreeCustomer' do
    card_type { Faker::Business.credit_card_type }
    card_bin ""
    cardholder_name { Faker::Name.name }
    card_debit "MyString"
    card_last_4 { Faker::Number.number(4) }
    default_payment_method_token nil
    card_unique_number_identifier{ "cuni#{Faker::Number.number(6)}" }
    email { Faker::Internet.email }
    first_name "MyString"
    last_name "MyString"
    customer_id { Faker::Number.number(6) }

    trait :with_payment_method_tokens do
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
          tokens.push({
                          braintree_payment_method_token: Faker::Lorem.characters(i+4),
                          customer_id: customer.customer_id
                      })
        end
        # Make sure that the token described in customer.default_payment_method_token is a part of the customer's
        # newly generated braintree payment method tokens.
        customer.default_payment_method_token = tokens.map { |t| FactoryGirl.create(:braintree_payment_method_token, t) }.last
      end

    end

  end
end
