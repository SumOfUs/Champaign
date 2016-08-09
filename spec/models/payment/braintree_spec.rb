# frozen_string_literal: true
require 'rails_helper'

xdescribe Payment::Braintree do
  describe '.customer' do
    let(:email) { 'foo@example.com' }

    it 'can find customer by member' do
      member = create :member, email: email
      customer = create :payment_braintree_customer, email: 'derp', member: member
      expect(Payment::Braintree.customer(email)).to eq customer
    end

    it 'can find customer by email' do
      customer = create :payment_braintree_customer, email: email, member: nil
      expect(Payment::Braintree.customer(email)).to eq customer
    end

    it 'prioritizes customer found by email' do
      member = create :member, email: email
      red_herring = create :payment_braintree_customer, email: 'derp', member: member
      the_right_one = create :payment_braintree_customer, email: email, member: nil
      expect(Payment::Braintree.customer(email)).to eq the_right_one
    end
  end

  describe '.write_subscription' do
    let(:subscription) { instance_double('Braintree::Subscription', id: 'lol', price: 12, merchant_account_id: 'EUR') }
    let(:success_result) { instance_double('Braintree::SuccessResult', success?: true, subscription: subscription) }
    let(:failure_result) { instance_double('Braintree::ErrorResult', success?: false) }

    before :each do
      allow(Payment::Braintree::Subscription).to receive(:create)
    end

    it 'saves relevant fields when successful' do
      Payment::Braintree.write_subscription(success_result, 'my_page_id', 'my_action_id', 'my_currency')
      expect(Payment::Braintree::Subscription).to have_received(:create).with(subscription_id:        'lol',
                                                                              amount:                 12,
                                                                              merchant_account_id:    'EUR',
                                                                              currency:               'my_currency',
                                                                              page_id:                'my_page_id',
                                                                              action_id:              'my_action_id')
    end

    it 'does not record when unsuccessful' do
      expect do
        Payment::Braintree.write_subscription(failure_result, 'my_page_id', 'my_action_id', 'my_currency')
      end.not_to change { Payment::Braintree::Subscription.count }
      expect(Payment::Braintree::Subscription).not_to have_received(:create)
    end
  end

  describe '.write_customer' do
    let(:bt_customer) { create :payment_braintree_customer, customer_id: 'fuds7', email: 'skeebadee@boop.beep' }
    let!(:member) { create :member, id: 3 }

    before :each do
      allow(Payment::Braintree::Customer).to receive(:create)
    end

    describe 'paid with credit card' do
      let(:bt_payment_method) do
        instance_double(
          'Braintree::CreditCard',
          is_a?: Braintree::CreditCard,
          token: '4we1sd',
          card_type: 'Visa',
          bin: 'binn',
          cardholder_name: 'Alexander Hamilton',
          debit: 'debidyboobop',
          last_4: '9191',
          unique_number_identifier: 'fsdjk',
          expiration_date: '12/2019'
        )
      end

      let(:expected_params) do
        {
          customer_id:      bt_customer.id,
          member_id:        member.id,
          email:            bt_customer.email,
          card_type:        bt_payment_method.card_type,
          card_bin:         bt_payment_method.bin,
          cardholder_name:  bt_payment_method.cardholder_name,
          card_debit:       bt_payment_method.debit,
          card_last_4:      bt_payment_method.last_4,
          card_unique_number_identifier: bt_payment_method.unique_number_identifier
        }
      end

      before :each do
        allow(Payment::Braintree::Customer).to receive(:create).and_return(bt_customer)
      end

      it 'writes the correct attributes if no existing customer' do
        Payment::Braintree.write_customer(bt_customer, bt_payment_method, member.id, nil)
        expect(Payment::Braintree::Customer).to have_received(:create).with(expected_params)
      end

      it 'writes the correct attributes with existing customer' do
        customer = build :payment_braintree_customer
        allow(customer).to receive(:update)
        Payment::Braintree.write_customer(bt_customer, bt_payment_method, member.id, customer)
        expect(customer).to have_received(:update).with(expected_params)
      end
    end

    describe 'paid with paypal' do
      let(:bt_payment_method) do
        instance_double('Braintree::PayPalAccount',
                        class: Braintree::PayPalAccount,
                        token: '4we2sd')
      end
      let(:expected_params) do
        {
          customer_id:      bt_customer.id,
          member_id:        member.id,
          email:            bt_customer.email,
          card_last_4:      'PYPL'
        }
      end

      before :each do
        allow(Payment::Braintree::Customer).to receive(:create).and_return(bt_customer)
      end

      it 'writes the correct attributes if no existing customer' do
        Payment::Braintree.write_customer(bt_customer, bt_payment_method, member.id, nil)
        expect(Payment::Braintree::Customer).to have_received(:create).with(expected_params)
      end

      it 'writes the correct attributes with existing customer' do
        customer = build :payment_braintree_customer
        allow(customer).to receive(:update)
        Payment::Braintree.write_customer(bt_customer, bt_payment_method, member.id, customer)
        expect(customer).to have_received(:update).with(expected_params)
      end
    end
  end

  describe '.write_transaction' do
    let!(:page_id) { 4567 }
    let!(:page) { create :page, id: 4567 }
    let!(:member) { create :member, id: 5678 }
    let(:new_member) { create :member, id: 1234, email: 'guybrush@threepwood.com' }
    let!(:existing_customer) { create :payment_braintree_customer, member_id: member.id, customer_id: '123' }
    let(:transaction) do
      instance_double('Braintree::Transaction',
                      id: 'sfjdjkl',
                      type: 'payment',
                      payment_instrument_type: payment_instrument_type,
                      amount: '432.12',
                      created_at: 2.minutes.ago,
                      merchant_account_id: 'EUR',
                      processor_response_code: 1000,
                      currency_iso_code: 'EUR',
                      customer_details: double(id: '123', email: 'wink@nod.com'),
                      credit_card_details: credit_card_details,
                      paypal_details: paypal_details)
    end

    let(:new_customer_transaction) do
      instance_double('Braintree::Transaction',
                      id: 'asdfg',
                      type: 'payment',
                      payment_instrument_type: payment_instrument_type,
                      amount: '432.12',
                      created_at: 2.minutes.ago,
                      merchant_account_id: 'EUR',
                      processor_response_code: 1000,
                      currency_iso_code: 'EUR',
                      customer_details: double(id: '123456', email: 'guybrush@threepwood.com'),
                      credit_card_details: credit_card_details,
                      paypal_details: paypal_details)
    end
    let!(:paypal_token) { create :braintree_payment_method, token: 'pp_token' }
    let!(:credit_card_token) { create :braintree_payment_method, token: 'cc_token' }

    let(:transaction_params) do
      {
        transaction_id:                  transaction.id,
        transaction_type:                transaction.type,
        payment_instrument_type:         transaction.payment_instrument_type,
        amount:                          transaction.amount,
        transaction_created_at:          transaction.created_at,
        merchant_account_id:             transaction.merchant_account_id,
        processor_response_code:         transaction.processor_response_code,
        currency:                        transaction.currency_iso_code,
        customer_id:                     existing_customer.customer_id,
        status:                          status,
        # Since we always create a new payment method token before the transaction, the id of the new token will with
        # the current implementation always be that of the last token created.
        payment_method_id: Payment::Braintree::PaymentMethod.last.id,
        page_id:                 page_id
      }
    end

    let(:new_customer_transaction_params) do
      {
        transaction_id:                  new_customer_transaction.id,
        transaction_type:                new_customer_transaction.type,
        payment_instrument_type:         new_customer_transaction.payment_instrument_type,
        amount:                          new_customer_transaction.amount,
        transaction_created_at:          new_customer_transaction.created_at,
        merchant_account_id:             new_customer_transaction.merchant_account_id,
        processor_response_code:         new_customer_transaction.processor_response_code,
        currency:                        new_customer_transaction.currency_iso_code,
        customer_id:                     '123456',
        status:                          status,
        # Since we always create a new payment method token before the transaction, the id of the new token will with
        # the current implementation always be that of the last token created.
        payment_method_id: Payment::Braintree::PaymentMethod.last.id,
        page_id:                 page_id
      }
    end

    before :each do
      allow(Payment::Braintree::Customer).to receive(:create)
      allow(Payment::Braintree::Transaction).to receive(:create!)
      allow(existing_customer).to receive(:update)
    end

    describe 'paid with credit card' do
      let(:payment_instrument_type) { 'credit_card' }
      let(:payment_method_token) { credit_card_token }
      let(:customer_params) do
        {
          card_type:        credit_card_details.card_type,
          card_bin:         credit_card_details.bin,
          cardholder_name:  credit_card_details.cardholder_name,
          card_debit:       credit_card_details.debit,
          card_last_4:      credit_card_details.last_4,
          customer_id:      transaction.customer_details.id,
          email:            transaction.customer_details.email,
          member_id:        member.id
        }
      end
      let(:credit_card_details) do
        instance_double('Braintree::Transaction::CreditCardDetails',
                        token: credit_card_token,
                        card_type: 'Visa',
                        bin: 'binn',
                        cardholder_name: 'Alexander Hamilton',
                        debit: 'debidyboobop',
                        last_4: '9191')
      end
      let(:paypal_details) { nil }

      describe 'with successful transaction' do
        let(:bt_result) { instance_double('Braintree::SuccessResult', transaction: transaction, success?: true) }
        let(:new_customer_bt_result) { instance_double('Braintree::SuccessResult', transaction: new_customer_transaction, success?: true) }

        let(:status) { Payment::Braintree::Transaction.statuses[:success] }

        it 'creates a transaction with the right attributes if an existing customer' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer)
          expect(Payment::Braintree::Transaction).to have_received(:create!).with(transaction_params)
        end

        it 'creates a transaction with the right attributes if a new customer' do
          Payment::Braintree.write_transaction(new_customer_bt_result, page_id, member.id, nil)
          expect(Payment::Braintree::Transaction).to have_received(:create!).with(new_customer_transaction_params)
        end

        it 'updates the existing_customer with the right attributes' do
          allow(Payment::Braintree::Customer).to receive(:find_or_create_by!).and_return(existing_customer)
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer)
          expect(existing_customer).to have_received(:update).with(customer_params)
        end

        it 'does not update or create customer if save_customer=false' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, nil, false)
          expect(Payment::Braintree::Customer).not_to have_received(:create)
          expect(existing_customer).not_to have_received(:update)
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer, false)
          expect(Payment::Braintree::Customer).not_to have_received(:create)
          expect(existing_customer).not_to have_received(:update)
        end
      end

      describe 'with unsuccessful transaction' do
        let(:bt_result) { instance_double('Braintree::ErrorResult', transaction: transaction, success?: false) }
        let(:status) { Payment::Braintree::Transaction.statuses[:failure] }

        it 'creates a transaction with the right attributes if an existing customer' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer)
          expect(Payment::Braintree::Transaction).to have_received(:create!).with(transaction_params)
        end

        it 'creates a transaction with the right attributes if a new customer' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, nil)
          expect(Payment::Braintree::Transaction).to have_received(:create!).with(transaction_params)
        end

        it 'does not create a new customer' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, nil)
          expect(Payment::Braintree::Customer).not_to have_received(:create)
        end

        it 'does not update existing_customer' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer)
          expect(existing_customer).not_to have_received(:update)
        end

        it 'does not update or create customer if save_customer=false' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, nil, false)
          expect(Payment::Braintree::Customer).not_to have_received(:create)
          expect(existing_customer).not_to have_received(:update)
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer, false)
          expect(Payment::Braintree::Customer).not_to have_received(:create)
          expect(existing_customer).not_to have_received(:update)
        end
      end

      describe 'with successful subscription' do
        let(:bt_result) { instance_double('Braintree::SuccessResult', subscription: double(transactions: [transaction]), success?: true, transaction: nil) }
        let(:status) { Payment::Braintree::Transaction.statuses[:success] }

        it 'creates a transaction with the right attributes if an existing customer' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer)
          expect(Payment::Braintree::Transaction).to have_received(:create!).with(transaction_params)
        end

        it 'creates a transaction with the right attributes if a new customer' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, nil)
          expect(Payment::Braintree::Transaction).to have_received(:create!).with(transaction_params)
        end

        it 'updates the existing_customer with the right attributes' do
          allow(Payment::Braintree::Customer).to receive(:find_or_create_by!).and_return(existing_customer)
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer)
          expect(existing_customer).to have_received(:update).with(customer_params)
        end

        it 'does not update or create customer if save_customer=false' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, nil, false)
          expect(Payment::Braintree::Customer).not_to have_received(:create)
          expect(existing_customer).not_to have_received(:update)
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer, false)
          expect(Payment::Braintree::Customer).not_to have_received(:create)
          expect(existing_customer).not_to have_received(:update)
        end
      end

      describe 'with unsuccessful subscription' do
        let(:bt_result) { instance_double('Braintree::ErrorResult', subscription: double(transactions: []), success?: false, transaction: nil) }
        let(:status) { Payment::Braintree::Transaction.statuses[:failure] }

        it 'does not create a transaction' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer)
          expect(Payment::Braintree::Transaction).not_to have_received(:create!)
        end

        it 'does not create a new customer' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, nil)
          expect(Payment::Braintree::Customer).not_to have_received(:create)
        end

        it 'does not update existing_customer' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer)
          expect(existing_customer).not_to have_received(:update)
        end
      end
    end

    describe 'paid with PayPal' do
      let(:payment_instrument_type) { 'paypal_account' }
      let(:payment_method_token) { paypal_token }
      let(:customer_params) do
        {
          card_type:        nil,
          card_bin:         nil,
          cardholder_name:  nil,
          card_debit:       'Unknown',
          customer_id:      transaction.customer_details.id,
          card_last_4:      'PYPL',
          email:            transaction.customer_details.email,
          member_id:        member.id
        }
      end
      let(:credit_card_details) { double('Braintree::Transaction::CreditCardDetails', card_type: nil, last_4: nil, bin: nil, cardholder_name: nil, debit: 'Unknown') }
      let(:paypal_details) { double('Braintree::Transaction::PayPalDetails', token: paypal_token) }

      describe 'with successful transaction' do
        let(:bt_result) { instance_double('Braintree::SuccessResult', transaction: transaction, success?: true) }
        let(:status) { Payment::Braintree::Transaction.statuses[:success] }
        let(:new_customer) { build :payment_braintree_customer }

        it 'creates a transaction with the right attributes if an existing customer' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer)
          expect(Payment::Braintree::Transaction).to have_received(:create!).with(transaction_params)
        end

        it 'creates a transaction with the right attributes if a new customer' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, nil)
          expect(Payment::Braintree::Transaction).to have_received(:create!).with(transaction_params)
        end

        it 'updates the existing_customer with the right attributes' do
          allow(Payment::Braintree::Customer).to receive(:find_or_create_by!).and_return(existing_customer)
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer)
          expect(existing_customer).to have_received(:update).with(customer_params)
        end

        it 'creates a new customer with the right attributes' do
          allow(Payment::Braintree::Customer).to receive(:find_or_create_by!).and_return(new_customer)
          allow(new_customer).to receive(:update)
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, nil)
          expect(Payment::Braintree::Customer).to have_received(:find_or_create_by!)
          expect(new_customer).to have_received(:update).with(customer_params)
        end

        it 'does not update or create customer if save_customer=false' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, nil, false)
          expect(Payment::Braintree::Customer).not_to have_received(:create)
          expect(existing_customer).not_to have_received(:update)
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer, false)
          expect(Payment::Braintree::Customer).not_to have_received(:create)
          expect(existing_customer).not_to have_received(:update)
        end
      end

      describe 'with unsuccessful transaction' do
        let(:bt_result) { instance_double('Braintree::ErrorResult', transaction: transaction, success?: false) }
        let(:status) { Payment::Braintree::Transaction.statuses[:failure] }

        it 'creates a transaction with the right attributes if an existing customer' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer)
          expect(Payment::Braintree::Transaction).to have_received(:create!).with(transaction_params)
        end

        it 'creates a transaction with the right attributes if a new customer' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, nil)
          expect(Payment::Braintree::Transaction).to have_received(:create!).with(transaction_params)
        end

        it 'does not create a new customer' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, nil)
          expect(Payment::Braintree::Customer).not_to have_received(:create)
        end

        it 'does not update existing_customer' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer)
          expect(existing_customer).not_to have_received(:update)
        end

        it 'does not update or create customer if save_customer=false' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, nil, false)
          expect(Payment::Braintree::Customer).not_to have_received(:create)
          expect(existing_customer).not_to have_received(:update)
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer, false)
          expect(Payment::Braintree::Customer).not_to have_received(:create)
          expect(existing_customer).not_to have_received(:update)
        end
      end

      describe 'with successful subscription' do
        let(:new_customer) { build :payment_braintree_customer }
        let(:bt_result) { instance_double('Braintree::SuccessResult', subscription: double(transactions: [transaction]), success?: true, transaction: nil) }
        let(:status) { Payment::Braintree::Transaction.statuses[:success] }

        it 'creates a transaction with the right attributes if an existing customer' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer)
          expect(Payment::Braintree::Transaction).to have_received(:create!).with(transaction_params)
        end

        it 'creates a transaction with the right attributes if a new customer' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, nil)
          expect(Payment::Braintree::Transaction).to have_received(:create!).with(transaction_params)
        end

        it 'updates the existing_customer with the right attributes' do
          allow(Payment::Braintree::Customer).to receive(:find_or_create_by!).and_return(existing_customer)
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer)
          expect(existing_customer).to have_received(:update).with(customer_params)
        end

        it 'creates a new customer with the right attributes' do
          allow(Payment::Braintree::Customer).to receive(:find_or_create_by!).and_return(new_customer)
          allow(new_customer).to receive(:update)
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, nil)
          expect(Payment::Braintree::Customer).to have_received(:find_or_create_by!)
          expect(new_customer).to have_received(:update).with(customer_params)
        end

        it 'does not update or create customer if save_customer=false' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, nil, false)
          expect(Payment::Braintree::Customer).not_to have_received(:create)
          expect(existing_customer).not_to have_received(:update)
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer, false)
          expect(Payment::Braintree::Customer).not_to have_received(:create)
          expect(existing_customer).not_to have_received(:update)
        end
      end

      describe 'with unsuccessful subscription' do
        let(:bt_result) { instance_double('Braintree::ErrorResult', subscription: double(transactions: []), success?: false, transaction: nil) }
        let(:status) { Payment::Braintree::Transaction.statuses[:failure] }

        it 'does not create a transaction' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer)
          expect(Payment::Braintree::Transaction).not_to have_received(:create!)
        end

        it 'does not create a new customer' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, nil)
          expect(Payment::Braintree::Customer).not_to have_received(:create)
        end

        it 'does not update existing_customer' do
          Payment::Braintree.write_transaction(bt_result, page_id, member.id, existing_customer)
          expect(existing_customer).not_to have_received(:update)
        end
      end
    end
  end
end
