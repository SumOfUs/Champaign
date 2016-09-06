FactoryGirl.define do
  factory :payment_braintree_notification, class: 'Payment::Braintree::Notification' do
    payload "MyText"
    signature "MyText"
  end
end
