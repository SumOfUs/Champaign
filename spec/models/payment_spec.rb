require 'rails_helper'

describe Payment do
  describe '.customer' do

    let(:email) { 'foo@example.com' }

    it 'can find customer by member' do
      member = create :member, email: email
      customer = create :payment_braintree_customer, email: 'derp', member: member
      expect(Payment.customer(email)).to eq customer
    end

    it 'can find customer by email' do
      customer = create :payment_braintree_customer, email: email, member: nil
      expect(Payment.customer(email)).to eq customer
    end

    it 'prioritizes customer found by email' do
      member = create :member, email: email
      red_herring = create :payment_braintree_customer, email: 'derp', member: member
      the_right_one = create :payment_braintree_customer, email: email, member: nil
      expect(Payment.customer(email)).to eq the_right_one
    end
  end

  describe '.write_subscription' do

    let(:subscription) { instance_double('Braintree::Subscription', id: 'lol', price: 12, merchant_account_id: 'EUR')}
    let(:success_result){ instance_double('Braintree::SuccessResult', success?: true, subscription: subscription) }
    let(:failure_result){ instance_double('Braintree::ErrorResult', success?: false) }

    before :each do
      allow(Payment::BraintreeSubscription).to receive(:create)
    end

    it 'saves relevant fields when successful' do
      Payment.write_subscription(success_result, 'my_page_id', 'my_currency')
      expect(Payment::BraintreeSubscription).to have_received(:create).with({
        subscription_id:        'lol',
        amount:                 12,
        merchant_account_id:    'EUR',
        currency:               'my_currency',
        page_id:                'my_page_id'
      })
    end

    it 'does not record when unsuccessful' do
      expect{
        Payment.write_subscription(failure_result, 'my_page_id', 'my_currency')
      }.not_to change{ Payment::BraintreeSubscription.count }
      expect(Payment::BraintreeSubscription).not_to have_received(:create)
    end
  end


end
