require 'rails_helper'

describe "Braintree API" do

  let(:page) { create(:page, title: 'Cash rules everything around me') }
  let(:form) { create(:form) }
  let(:four_digits) { /[0-9]{4}/ }
  let(:token_format) { /[a-z0-9]{1,36}/i }
  let(:user_params) do
    {
      form_id: form.id,
      name: "Bernie Sanders",
      email: "itsme@feelthebern.org",
      postal: "11225",
      address1: '25 Elm Drive',
      akid: '1234.5678.9910',
      source: 'fb',
      country: "US"
    }
  end

  let(:donation_push_params) do
    {
      type: "donation",
      params: {
        donationpage: {
          name: "cash-rules-everything-around-me-donation",
          payment_account: "Braintree EUR"
        },
        order: {
          amount: amount.to_s,
          card_num: "1881",
          card_code: "007",
          exp_date_month: "12",
          exp_date_year: "2020",
          currency: "EUR"
        },
        user: {
          email: "itsme@feelthebern.org",
          country: "United States",
          postal: "11225",
          address1: '25 Elm Drive',
          first_name: 'Bernie',
          last_name: 'Sanders',
          akid: '1234.5678.9910',
          source: 'fb',
          user_en: 1
        },
        action: {
          source: 'fb'
        }
      }
    }
  end

  before :each do
    allow(ChampaignQueue).to receive(:push)
    allow(Analytics::Page).to receive(:increment)
  end

  describe 'making a transaction' do
    describe 'successfully' do

      let(:basic_params) do
        {
          currency: 'EUR',
          payment_method_nonce: 'fake-valid-nonce',
          # amount: amount, # should override for each casette to avoid duplicates
          recurring: false
        }
      end

      context 'when Member exists' do

        let!(:member) { create :member, email: user_params[:email], postal: nil }

        context 'when BraintreeCustomer exists' do

          let!(:customer) { create :payment_braintree_customer, member: member, customer_id: 'test', card_last_4: '4843' }

          context 'with basic params' do

            let(:amount) { 23.20 } # to avoid duplicate donations recording specs
            let(:params) { basic_params.merge(user: user_params, amount: amount) }
            subject do
              VCR.use_cassette("transaction success basic existing customer") do
                post api_braintree_transaction_path(page.id), params
              end
            end

            it 'increments redis counters' do
              expect(Analytics::Page).to receive(:increment).with(page.id, new_member: false)
              subject
            end

            it "creates an Action associated with the Page and Member" do
              expect{ subject }.to change{ Action.count }.by 1
              expect(Action.last.page).to eq page
              expect(Action.last.member).to eq member
            end

            it "stores amount, currency, card_num, is_subscription, and transaction_id in form_data on the Action" do
              expect{ subject }.to change{ Action.count }.by 1
              form_data = Action.last.form_data
              expect(form_data['card_num']).to eq '1881'
              expect(form_data['is_subscription']).to eq false
              expect(form_data['amount']).to eq amount.to_s
              expect(form_data['currency']).to eq 'EUR'
              expect(form_data['transaction_id']).to eq Payment::BraintreeTransaction.last.transaction_id
            end

            it "creates a Transaction associated with the page storing relevant info" do
              expect{ subject }.to change{ Payment::BraintreeTransaction.count }.by 1
              transaction = Payment::BraintreeTransaction.last
              expect(transaction.page).to eq page
              expect(transaction.amount).to eq amount
              expect(transaction.currency).to eq 'EUR'
              expect(transaction.merchant_account_id).to eq 'EUR'
              expect(transaction.payment_instrument_type).to eq 'credit_card'
              expect(transaction.transaction_type).to eq 'sale'
              expect(transaction.customer_id).to eq customer.customer_id
              expect(transaction.status).to eq 'success'

              expect(Payment::BraintreePaymentMethodToken.find(transaction.payment_method_token_id).
                         braintree_payment_method_token).to match a_string_matching(token_format)
              expect(transaction.transaction_id).to match a_string_matching(token_format)
            end

            it "updates Payment::BraintreeCustomer with new token and last_4" do
              previous_token = customer.default_payment_method_token
              previous_last_4 = customer.card_last_4
              expect{ subject }.to change{ Payment::BraintreeCustomer.count }.by 0
              new_token = Payment::BraintreePaymentMethodToken.last
              customer.reload
              expect( customer.default_payment_method_token ).to_not eq previous_token
              expect( customer.default_payment_method_token ).to eq Payment::BraintreePaymentMethodToken.last
              expect( customer.card_last_4 ).to match a_string_matching(four_digits)
              expect( customer.card_last_4 ).not_to eq previous_last_4
            end

            it "posts donation action to queue with key data" do
              subject
              expect( ChampaignQueue ).to have_received(:push).with(donation_push_params)
            end

            it "increments action count on page" do
              expect{ subject }.to change{ page.reload.action_count }.by 1
            end

            it "passes the params to braintree" do
              allow(Braintree::Transaction).to receive(:sale).and_call_original
              subject
              expect(Braintree::Transaction).to have_received(:sale).with({
                amount: amount,
                payment_method_nonce: "fake-valid-nonce",
                merchant_account_id: "EUR",
                options: {
                  submit_for_settlement: true,
                  store_in_vault_on_success: true
                },
                customer: {
                  first_name: "Bernie",
                  last_name: "Sanders",
                  email: "itsme@feelthebern.org"
                },
                billing: {
                  first_name: "Bernie",
                  last_name: "Sanders",
                  street_address: "25 Elm Drive",
                  postal_code: '11225',
                  country_code_alpha2: 'US'
                },
                customer_id: customer.customer_id
              })
            end

            it "leaves a cookie with the member_id" do
              expect(cookies['member_id']).to eq nil
              subject

              # we can't access signed cookies in request specs, so check for hashed value
              expect(cookies['member_id']).not_to eq nil
              expect(cookies['member_id'].length).to be > 20
            end

            it "updates the Member’s fields with any new data" do
              expect(member.first_name).not_to eq 'Bernie'
              expect(member.last_name).not_to eq 'Sanders'
              expect(member.postal).to eq nil
              expect{ subject }.to change{ Member.count }.by 0
              member.reload
              expect(member.first_name).to eq 'Bernie'
              expect(member.last_name).to eq 'Sanders'
              expect(member.postal).to eq '11225'
            end

            it 'responds successfully with transaction_id' do
              subject
              transaction_id = Payment::BraintreeTransaction.last.transaction_id
              expect(response.status).to eq 200
              expect(response.body).to eq({ success: true, transaction_id: transaction_id }.to_json)
            end
          end

          context 'with Paypal' do

            let(:amount) { 29.20 } # to avoid duplicate donations recording specs
            let(:params) { basic_params.merge(user: user_params, payment_method_nonce: 'fake-paypal-future-nonce', amount: amount) }

            subject do
              VCR.use_cassette("transaction success paypal existing customer") do
                post api_braintree_transaction_path(page.id), params
              end
            end

            it "creates a Transaction associated with the page storing relevant info" do
              expect{ subject }.to change{ Payment::BraintreeTransaction.count }.by 1
              transaction = Payment::BraintreeTransaction.last

              expect(transaction.page).to eq page
              expect(transaction.amount).to eq amount
              expect(transaction.currency).to eq 'EUR'
              expect(transaction.merchant_account_id).to eq 'EUR'
              expect(transaction.payment_instrument_type).to eq 'paypal_account'
              expect(transaction.transaction_type).to eq 'sale'
              expect(transaction.customer_id).to eq customer.customer_id
              expect(transaction.status).to eq 'success'

              expect(Payment::BraintreePaymentMethodToken.find(transaction.payment_method_token_id).
                         braintree_payment_method_token).to match a_string_matching(token_format)
              expect(transaction.transaction_id).to match a_string_matching(token_format)
            end

            it "updates Payment::BraintreeCustomer with new token and PYPL for last_4" do
              previous_token = customer.default_payment_method_token
              previous_last_4 = customer.card_last_4
              expect{ subject }.to change{ Payment::BraintreeCustomer.count }.by 0
              customer.reload
              expect( customer.default_payment_method_token.braintree_payment_method_token ).to match a_string_matching(token_format)
              expect( customer.default_payment_method_token ).to eq Payment::BraintreePaymentMethodToken.last
              expect( customer.default_payment_method_token ).not_to eq previous_token
              expect( customer.card_last_4 ).to eq 'PYPL'
            end

            it "stores PYPL as card_num on the Action" do
              expect{ subject }.to change{ Action.count }.by 1
              form_data = Action.last.form_data
              expect(form_data['card_num']).to eq 'PYPL'
              expect(form_data['is_subscription']).to eq false
              expect(form_data['amount']).to eq amount.to_s
              expect(form_data['currency']).to eq 'EUR'
              expect(form_data['transaction_id']).to eq Payment::BraintreeTransaction.last.transaction_id
            end

            it 'passes PYPL as card_num to queue' do
              subject
              expect( ChampaignQueue ).to have_received(:push).with(a_hash_including(
                params: a_hash_including( order: a_hash_including(card_num: 'PYPL') )
              ))
            end

            it 'responds successfully with transaction_id' do
              subject
              transaction_id = Payment::BraintreeTransaction.last.transaction_id
              expect(response.status).to eq 200
              expect(response.body).to eq({ success: true, transaction_id: transaction_id }.to_json)
            end

          end
        end

        context 'when BraintreeCustomer is new' do

          context 'with basic params' do

            let(:amount) { 13.20 } # to avoid duplicate donations recording specs
            let(:params) { basic_params.merge(user: user_params, amount: amount) }
            subject do
              VCR.use_cassette("transaction success basic new customer") do
                post api_braintree_transaction_path(page.id), params
              end
            end

            it "creates an Action associated with the Page and Member" do
              expect{ subject }.to change{ Action.count }.by 1
              expect(Action.last.page).to eq page
              expect(Action.last.member).to eq member
            end

            it "stores amount, currency, card_num, is_subscription, and transaction_id in form_data on the Action" do
              expect{ subject }.to change{ Action.count }.by 1
              form_data = Action.last.form_data
              expect(form_data['card_num']).to eq '1881'
              expect(form_data['is_subscription']).to eq false
              expect(form_data['amount']).to eq amount.to_s
              expect(form_data['currency']).to eq 'EUR'
              expect(form_data['transaction_id']).to eq Payment::BraintreeTransaction.last.transaction_id
            end

            it "creates a Transaction associated with the page storing relevant info" do
              expect{ subject }.to change{ Payment::BraintreeTransaction.count }.by 1
              transaction = Payment::BraintreeTransaction.last

              expect(transaction.page).to eq page
              expect(transaction.amount).to eq amount
              expect(transaction.currency).to eq 'EUR'
              expect(transaction.merchant_account_id).to eq 'EUR'
              expect(transaction.payment_instrument_type).to eq 'credit_card'
              expect(transaction.transaction_type).to eq 'sale'
              expect(transaction.customer_id).to eq Payment::BraintreeCustomer.last.customer_id
              expect(transaction.status).to eq 'success'

              expect(Payment::BraintreePaymentMethodToken.find(transaction.payment_method_token_id).
                         braintree_payment_method_token).to match a_string_matching(token_format)
              expect(transaction.transaction_id).to match a_string_matching(token_format)
            end

            it "creates new Payment::BraintreeCustomer including token, customer_id, and last four for credit card" do
              expect{ subject }.to change{ Payment::BraintreeCustomer.count }.by 1
              customer = Payment::BraintreeCustomer.last
              expect( customer.customer_id ).not_to be_blank
              expect( customer.card_last_4 ).to eq '1881'
              expect( customer.default_payment_method_token ).not_to be_blank
              expect( customer.email ).to eq user_params[:email]
            end

            it "posts donation action to queue with key data" do
              subject
              expect( ChampaignQueue ).to have_received(:push).with(donation_push_params)
            end

            it "increments action count on page" do
              expect{ subject }.to change{ page.reload.action_count }.by 1
            end

            it "passes the params to braintree" do
              allow(Braintree::Transaction).to receive(:sale).and_call_original
              subject
              expect(Braintree::Transaction).to have_received(:sale).with({
                amount: amount,
                payment_method_nonce: "fake-valid-nonce",
                merchant_account_id: "EUR",
                options: {
                  submit_for_settlement: true,
                  store_in_vault_on_success: true
                },
                customer: {
                  first_name: "Bernie",
                  last_name: "Sanders",
                  email: "itsme@feelthebern.org"
                },
                billing: {
                  first_name: "Bernie",
                  last_name: "Sanders",
                  street_address: "25 Elm Drive",
                  postal_code: '11225',
                  country_code_alpha2: 'US'
                }
              })
            end

            it "leaves a cookie with the member_id" do
              expect(cookies['member_id']).to eq nil
              subject

              # we can't access signed cookies in request specs, so check for hashed value
              expect(cookies['member_id']).not_to eq nil
              expect(cookies['member_id'].length).to be > 20
            end

            it "updates the Member’s fields with any new data" do
              expect(member.first_name).not_to eq 'Bernie'
              expect(member.last_name).not_to eq 'Sanders'
              expect(member.postal).to eq nil
              expect{ subject }.to change{ Member.count }.by 0
              member.reload
              expect(member.first_name).to eq 'Bernie'
              expect(member.last_name).to eq 'Sanders'
              expect(member.postal).to eq '11225'
            end

            it 'responds successfully with transaction_id' do
              subject
              transaction_id = Payment::BraintreeTransaction.last.transaction_id
              expect(response.status).to eq 200
              expect(response.body).to eq({ success: true, transaction_id: transaction_id }.to_json)
            end
          end

          context 'with Paypal' do

            let(:amount) { 19.20 } # to avoid duplicate donations recording specs
            let(:params) { basic_params.merge(user: user_params, payment_method_nonce: 'fake-paypal-future-nonce', amount: amount) }

            subject do
              VCR.use_cassette("transaction success paypal new customer") do
                post api_braintree_transaction_path(page.id), params
              end
            end

            it "creates a Transaction associated with the page storing relevant info" do
              expect{ subject }.to change{ Payment::BraintreeTransaction.count }.by 1
              transaction = Payment::BraintreeTransaction.last

              expect(transaction.page).to eq page
              expect(transaction.amount).to eq amount
              expect(transaction.currency).to eq 'EUR'
              expect(transaction.merchant_account_id).to eq 'EUR'
              expect(transaction.payment_instrument_type).to eq 'paypal_account'
              expect(transaction.transaction_type).to eq 'sale'
              expect(transaction.customer_id).to eq Payment::BraintreeCustomer.last.customer_id
              expect(transaction.status).to eq 'success'

              expect(Payment::BraintreePaymentMethodToken.find(transaction.payment_method_token_id).
                         braintree_payment_method_token).to match a_string_matching(token_format)
              expect(transaction.transaction_id).to match a_string_matching(token_format)
            end

            it "creates a Payment::BraintreeCustomer with customer_id and PYPL for last 4" do
              expect{ subject }.to change{ Payment::BraintreeCustomer.count }.by 1
              customer = Payment::BraintreeCustomer.last
              expect(customer.customer_id).not_to be_blank
              expect(customer.card_last_4).to eq 'PYPL'
              expect( customer.default_payment_method_token ).not_to be_blank
              expect( customer.email ).to eq user_params[:email]
            end

            it "stores PYPL as card_num on the Action" do
              expect{ subject }.to change{ Action.count }.by 1
              form_data = Action.last.form_data
              expect(form_data['card_num']).to eq 'PYPL'
              expect(form_data['is_subscription']).to eq false
              expect(form_data['amount']).to eq amount.to_s
              expect(form_data['currency']).to eq 'EUR'
              expect(form_data['transaction_id']).to eq Payment::BraintreeTransaction.last.transaction_id
            end

            it 'passes PYPL as card_num to queue' do
              subject
              expect( ChampaignQueue ).to have_received(:push).with(a_hash_including(
                params: a_hash_including( order: a_hash_including(card_num: 'PYPL') )
              ))
            end

            it 'responds successfully with transaction_id' do
              subject
              transaction_id = Payment::BraintreeTransaction.last.transaction_id
              expect(response.status).to eq 200
              expect(response.body).to eq({ success: true, transaction_id: transaction_id }.to_json)
            end
          end
        end
      end

      context 'when Member is new' do

        context 'when BraintreeCustomer is new' do

          context 'with basic params' do

            # we're using the same casette as above anyway, so we're only running specs
            # relevant to the new member

            let(:amount) { 13.20 } # to avoid duplicate donations recording specs
            let(:params) { basic_params.merge(user: user_params, amount: amount) }

            subject do
              VCR.use_cassette("transaction success basic new customer") do
                post api_braintree_transaction_path(page.id), params
              end
            end

            it 'increments redis counters' do
              expect(Analytics::Page).to receive(:increment).with(page.id, new_member: true)
              subject
            end

            it "creates an Action associated with the Page and Member" do
              expect{ subject }.to change{ Action.count }.by 1
              expect(Action.last.page).to eq page
              expect(Action.last.member).to eq Member.last
            end

            it "leaves a cookie with the member_id" do
              expect(cookies['member_id']).to eq nil
              subject

              # we can't access signed cookies in request specs, so check for hashed value
              expect(cookies['member_id']).not_to eq nil
              expect(cookies['member_id'].length).to be > 20
            end

            it "populates the Member’s fields with form data" do
              expect{ subject }.to change{ Member.count }.by 1
              member = Member.last
              expect(member.first_name).to eq 'Bernie'
              expect(member.last_name).to eq 'Sanders'
              expect(member.postal).to eq '11225'
            end

            it 'responds successfully with transaction_id' do
              subject
              transaction_id = Payment::BraintreeTransaction.last.transaction_id
              expect(response.status).to eq 200
              expect(response.body).to eq({ success: true, transaction_id: transaction_id }.to_json)
            end
          end
        end
      end
    end
  end

  describe 'making a subscription' do
    describe 'successfully' do

      let(:basic_params) do
        {
          currency: 'EUR',
          payment_method_nonce: 'fake-valid-nonce',
          # amount: amount, # should override for each casette to avoid duplicates
          recurring: true
        }
      end

      context 'when Member exists' do

        let!(:member) { create :member, email: user_params[:email], postal: nil }

        context 'when BraintreeCustomer exists' do

          let!(:customer) { create :payment_braintree_customer, member: member, customer_id: 'test', card_last_4: '4843' }

          context 'with basic params' do

            let(:amount) { 823.20 } # to avoid duplicate donations recording specs
            let(:params) { basic_params.merge(user: user_params, amount: amount) }
            subject do
              VCR.use_cassette("subscription success basic existing customer") do
                post api_braintree_transaction_path(page.id), params
              end
            end

            it 'increments redis counters' do
              expect(Analytics::Page).to receive(:increment).with(page.id, new_member: false)
              subject
            end

            it "creates an Action associated with the Page and Member" do
              expect{ subject }.to change{ Action.count }.by 1
              expect(Action.last.page).to eq page
              expect(Action.last.member).to eq member
            end

            it "stores amount, currency, card_num, is_subscription, transaction_id, and subscription_id in form_data on the Action" do
              expect{ subject }.to change{ Action.count }.by 1
              form_data = Action.last.form_data
              expect(form_data['card_num']).to eq '1881'
              expect(form_data['is_subscription']).to eq true
              expect(form_data['amount']).to eq amount.to_s
              expect(form_data['currency']).to eq 'EUR'
              expect(form_data['subscription_id']).to eq Payment::BraintreeSubscription.last.subscription_id
              expect(form_data['transaction_id']).to eq Payment::BraintreeTransaction.last.transaction_id
            end

            it "creates a Transaction associated with the page storing relevant info" do
              expect{ subject }.to change{ Payment::BraintreeTransaction.count }.by 1
              transaction = Payment::BraintreeTransaction.last

              expect(transaction.page).to eq page
              expect(transaction.amount).to eq amount
              expect(transaction.currency).to eq 'EUR'
              expect(transaction.merchant_account_id).to eq 'EUR'
              expect(transaction.payment_instrument_type).to eq 'credit_card'
              expect(transaction.transaction_type).to eq 'sale'
              expect(transaction.customer_id).to eq customer.customer_id
              expect(transaction.status).to eq 'success'

              expect(Payment::BraintreePaymentMethodToken.find(transaction.payment_method_token_id).
                         braintree_payment_method_token).to match a_string_matching(token_format)
              expect(transaction.transaction_id).to match a_string_matching(token_format)
            end

            it "creates a Subscription associated with the page storing relevant info" do
              expect{ subject }.to change{ Payment::BraintreeSubscription.count }.by 1
              subscription = Payment::BraintreeSubscription.last

              expect(subscription.amount).to eq amount
              expect(subscription.currency).to eq 'EUR'
              expect(subscription.merchant_account_id).to eq 'EUR'
              expect(subscription.subscription_id).to match a_string_matching(token_format)
              expect(subscription.page).to eq page
              expect(subscription.action).to eq Action.last
            end

            it "updates Payment::BraintreeCustomer with new token and last_4" do
              previous_token = customer.default_payment_method_token
              previous_last_4 = customer.card_last_4
              expect{ subject }.to change{ Payment::BraintreeCustomer.count }.by 0
              customer.reload
              expect( customer.default_payment_method_token.braintree_payment_method_token ).to match a_string_matching(token_format)
              expect( customer.default_payment_method_token ).to eq Payment::BraintreePaymentMethodToken.last
              expect( customer.default_payment_method_token ).not_to eq previous_token
              expect( customer.card_last_4 ).to match a_string_matching(four_digits)
              expect( customer.card_last_4 ).not_to eq previous_last_4
            end

            it "posts donation action to queue with key data" do
              subject
              expect( ChampaignQueue ).to have_received(:push).with(donation_push_params)
            end

            it "increments action count on page" do
              expect{ subject }.to change{ page.reload.action_count }.by 1
            end

            it "passes the subscription params to braintree" do
              allow(Braintree::Subscription).to receive(:create).and_call_original
              subject
              expect(Braintree::Subscription).to have_received(:create).with({
                price: amount,
                payment_method_token: a_string_matching(token_format),
                merchant_account_id: "EUR",
                plan_id: 'EUR'
              })
            end

            it "passes the customer params to braintree" do
              allow(Braintree::Customer).to receive(:update).and_call_original
              subject
              expect(Braintree::Customer).to have_received(:update).with(customer.customer_id, {
                first_name: "Bernie",
                last_name: "Sanders",
                email: "itsme@feelthebern.org"
              })
            end

            it 'passes the payment params to braintree' do
              allow(Braintree::PaymentMethod).to receive(:create).and_call_original
              subject
              expect(Braintree::PaymentMethod).to have_received(:create).with({
                payment_method_nonce: 'fake-valid-nonce',
                customer_id: customer.customer_id,
                billing_address: {
                  first_name: "Bernie",
                  last_name: "Sanders",
                  street_address: "25 Elm Drive",
                  postal_code: '11225',
                  country_code_alpha2: 'US'
                }
              })
            end

            it "leaves a cookie with the member_id" do
              expect(cookies['member_id']).to eq nil
              subject

              # we can't access signed cookies in request specs, so check for hashed value
              expect(cookies['member_id']).not_to eq nil
              expect(cookies['member_id'].length).to be > 20
            end

            it "updates the Member’s fields with any new data" do
              expect(member.first_name).not_to eq 'Bernie'
              expect(member.last_name).not_to eq 'Sanders'
              expect(member.postal).to eq nil
              expect{ subject }.to change{ Member.count }.by 0
              member.reload
              expect(member.first_name).to eq 'Bernie'
              expect(member.last_name).to eq 'Sanders'
              expect(member.postal).to eq '11225'
            end

            it 'responds successfully with subscription_id' do
              subject
              subscription_id = Payment::BraintreeSubscription.last.subscription_id
              expect(response.status).to eq 200
              expect(response.body).to eq({ success: true, subscription_id: subscription_id }.to_json)
            end
          end

          context 'with Paypal' do

            let(:amount) { 829.20 } # to avoid duplicate donations recording specs
            let(:params) { basic_params.merge(user: user_params, payment_method_nonce: 'fake-paypal-future-nonce', amount: amount) }

            subject do
              VCR.use_cassette("subscription success paypal existing customer") do
                post api_braintree_transaction_path(page.id), params
              end
            end

            it 'increments redis counters' do
              expect(Analytics::Page).to receive(:increment).with(page.id, new_member: false)
              subject
            end

            it "creates a Transaction associated with the page storing relevant info" do
              expect{ subject }.to change{ Payment::BraintreeTransaction.count }.by 1
              transaction = Payment::BraintreeTransaction.last

              expect(transaction.page).to eq page
              expect(transaction.amount).to eq amount
              expect(transaction.currency).to eq 'EUR'
              expect(transaction.merchant_account_id).to eq 'EUR'
              expect(transaction.payment_instrument_type).to eq 'paypal_account'
              expect(transaction.transaction_type).to eq 'sale'
              expect(transaction.customer_id).to eq customer.customer_id
              expect(transaction.status).to eq 'success'

              expect(Payment::BraintreePaymentMethodToken.find(transaction.payment_method_token_id).
                         braintree_payment_method_token).to match a_string_matching(token_format)
              expect(transaction.transaction_id).to match a_string_matching(token_format)
            end

            it "updates Payment::BraintreeCustomer with new token and PYPL for last_4" do
              previous_token = customer.default_payment_method_token
              previous_last_4 = customer.card_last_4
              expect{ subject }.to change{ Payment::BraintreeCustomer.count }.by 0
              customer.reload
              expect( customer.default_payment_method_token.braintree_payment_method_token ).to match a_string_matching(token_format)
              expect( customer.default_payment_method_token ).to eq Payment::BraintreePaymentMethodToken.last
              expect( customer.default_payment_method_token ).not_to eq previous_token
              expect( customer.card_last_4 ).to_not eq previous_last_4
              expect( customer.card_last_4 ).to eq 'PYPL'
            end

            it "stores PYPL as card_num on the Action" do
              expect{ subject }.to change{ Action.count }.by 1
              form_data = Action.last.form_data
              expect(form_data['card_num']).to eq 'PYPL'
              expect(form_data['is_subscription']).to eq true
              expect(form_data['amount']).to eq amount.to_s
              expect(form_data['currency']).to eq 'EUR'
              expect(form_data['subscription_id']).to eq Payment::BraintreeSubscription.last.subscription_id
              expect(form_data['transaction_id']).to eq Payment::BraintreeTransaction.last.transaction_id
            end

            it 'passes PYPL as card_num to queue' do
              subject
              expect( ChampaignQueue ).to have_received(:push).with(a_hash_including(
                params: a_hash_including( order: a_hash_including(card_num: 'PYPL') )
              ))
            end

            it 'responds successfully with subscription_id' do
              subject
              subscription_id = Payment::BraintreeSubscription.last.subscription_id
              expect(response.status).to eq 200
              expect(response.body).to eq({ success: true, subscription_id: subscription_id }.to_json)
            end

          end
        end

        context 'when BraintreeCustomer is new' do

          context 'with basic params' do

            let(:amount) { 813.20 } # to avoid duplicate donations recording specs
            let(:params) { basic_params.merge(user: user_params, amount: amount) }

            subject do
              VCR.use_cassette("subscription success basic new customer") do
                post api_braintree_transaction_path(page.id), params
              end
            end

            it 'increments redis counters' do
              expect(Analytics::Page).to receive(:increment).with(page.id, new_member: false)
              subject
            end

            it "creates an Action associated with the Page and Member" do
              expect{ subject }.to change{ Action.count }.by 1
              expect(Action.last.page).to eq page
              expect(Action.last.member).to eq member
            end

            it "stores amount, currency, card_num, is_subscription, transaction_id, and subscription_id in form_data on the Action" do
              expect{ subject }.to change{ Action.count }.by 1
              form_data = Action.last.form_data
              expect(form_data['card_num']).to eq '1881'
              expect(form_data['is_subscription']).to eq true
              expect(form_data['amount']).to eq amount.to_s
              expect(form_data['currency']).to eq 'EUR'
              expect(form_data['subscription_id']).to eq Payment::BraintreeSubscription.last.subscription_id
              expect(form_data['transaction_id']).to eq Payment::BraintreeTransaction.last.transaction_id
            end

            it "creates a Transaction associated with the page storing relevant info" do
              expect{ subject }.to change{ Payment::BraintreeTransaction.count }.by 1
              transaction = Payment::BraintreeTransaction.last

              expect(transaction.page).to eq page
              expect(transaction.amount).to eq amount
              expect(transaction.currency).to eq 'EUR'
              expect(transaction.merchant_account_id).to eq 'EUR'
              expect(transaction.payment_instrument_type).to eq 'credit_card'
              expect(transaction.transaction_type).to eq 'sale'
              expect(transaction.customer_id).to eq Payment::BraintreeCustomer.last.customer_id
              expect(transaction.status).to eq 'success'

              expect(Payment::BraintreePaymentMethodToken.find(transaction.payment_method_token_id).
                         braintree_payment_method_token).to match a_string_matching(token_format)
              expect(transaction.transaction_id).to match a_string_matching(token_format)
            end

            it "creates a Subscription associated with the page storing relevant info" do
              expect{ subject }.to change{ Payment::BraintreeSubscription.count }.by 1
              subscription = Payment::BraintreeSubscription.last

              expect(subscription.amount).to eq amount
              expect(subscription.currency).to eq 'EUR'
              expect(subscription.merchant_account_id).to eq 'EUR'
              expect(subscription.subscription_id).to match a_string_matching(token_format)
              expect(subscription.page).to eq page
              expect(subscription.action).to eq Action.last
            end

            it "creates a Payment::BraintreeCustomer with new token, customer_id, and last_4" do
              expect{ subject }.to change{ Payment::BraintreeCustomer.count }.by 1
              customer = Payment::BraintreeCustomer.last
              expect(customer.customer_id).to match a_string_matching(token_format)
              expect(customer.default_payment_method_token.braintree_payment_method_token).to match a_string_matching(token_format)
              expect( customer.email ).to eq user_params[:email]
              expect(customer.card_last_4).to match a_string_matching(four_digits)
            end

            it "posts donation action to queue with key data" do
              subject
              expect( ChampaignQueue ).to have_received(:push).with(donation_push_params)
            end

            it "increments action count on page" do
              expect{ subject }.to change{ page.reload.action_count }.by 1
            end

            it "passes the subscription params to braintree" do
              allow(Braintree::Subscription).to receive(:create).and_call_original
              subject
              expect(Braintree::Subscription).to have_received(:create).with({
                price: amount,
                payment_method_token: a_string_matching(token_format),
                merchant_account_id: "EUR",
                plan_id: 'EUR'
              })
            end

            it "passes the customer params and nonce to braintree" do
              allow(Braintree::Customer).to receive(:create).and_call_original
              subject
              expect(Braintree::Customer).to have_received(:create).with({
                first_name: "Bernie",
                last_name: "Sanders",
                payment_method_nonce: 'fake-valid-nonce',
                email: "itsme@feelthebern.org",
                credit_card: {
                  billing_address: {
                    first_name: "Bernie",
                    last_name: "Sanders",
                    street_address: "25 Elm Drive",
                    postal_code: '11225',
                    country_code_alpha2: 'US'
                  }
                }
              })
            end

            it 'does not create payment method separately' do

              allow(Braintree::PaymentMethod).to receive(:create).and_call_original
              subject
              expect(Braintree::PaymentMethod).not_to have_received(:create)
            end

            it "leaves a cookie with the member_id" do
              expect(cookies['member_id']).to eq nil
              subject

              # we can't access signed cookies in request specs, so check for hashed value
              expect(cookies['member_id']).not_to eq nil
              expect(cookies['member_id'].length).to be > 20
            end

            it "updates the Member’s fields with any new data" do
              expect(member.first_name).not_to eq 'Bernie'
              expect(member.last_name).not_to eq 'Sanders'
              expect(member.postal).to eq nil
              expect{ subject }.to change{ Member.count }.by 0
              member.reload
              expect(member.first_name).to eq 'Bernie'
              expect(member.last_name).to eq 'Sanders'
              expect(member.postal).to eq '11225'
            end

            it 'responds successfully with subscription_id' do
              subject
              subscription_id = Payment::BraintreeSubscription.last.subscription_id
              expect(response.status).to eq 200
              expect(response.body).to eq({ success: true, subscription_id: subscription_id }.to_json)
            end
          end

          context 'with Paypal' do

            let(:amount) { 819.20 } # to avoid duplicate donations recording specs
            let(:params) { basic_params.merge(user: user_params, payment_method_nonce: 'fake-paypal-future-nonce', amount: amount) }

            subject do
              VCR.use_cassette("subscription success paypal new customer") do
                post api_braintree_transaction_path(page.id), params
              end
            end

            it 'increments redis counters' do
              expect(Analytics::Page).to receive(:increment).with(page.id, new_member: false)
              subject
            end

            it "creates a Transaction associated with the page storing relevant info" do
              expect{ subject }.to change{ Payment::BraintreeTransaction.count }.by 1
              transaction = Payment::BraintreeTransaction.last

              expect(transaction.page).to eq page
              expect(transaction.amount).to eq amount
              expect(transaction.currency).to eq 'EUR'
              expect(transaction.merchant_account_id).to eq 'EUR'
              expect(transaction.payment_instrument_type).to eq 'paypal_account'
              expect(transaction.transaction_type).to eq 'sale'
              expect(transaction.customer_id).to eq Payment::BraintreeCustomer.last.customer_id
              expect(transaction.status).to eq 'success'

              expect(Payment::BraintreePaymentMethodToken.find(transaction.payment_method_token_id).
                         braintree_payment_method_token).to match a_string_matching(token_format)
              
              expect(transaction.transaction_id).to match a_string_matching(token_format)
            end

            it "creates a Payment::BraintreeCustomer with customer_id and PYPL for last 4" do
              expect{ subject }.to change{ Payment::BraintreeCustomer.count }.by 1
              customer = Payment::BraintreeCustomer.last
              expect(customer.customer_id).to match a_string_matching(token_format)
              expect(customer.default_payment_method_token.braintree_payment_method_token).to match a_string_matching(token_format)
              expect( customer.email ).to eq user_params[:email]
              expect( customer.reload.card_last_4 ).to eq 'PYPL'
            end

            it "stores PYPL as card_num on the Action" do
              expect{ subject }.to change{ Action.count }.by 1
              form_data = Action.last.form_data
              expect(form_data['card_num']).to eq 'PYPL'
              expect(form_data['is_subscription']).to eq true
              expect(form_data['amount']).to eq amount.to_s
              expect(form_data['currency']).to eq 'EUR'
              expect(form_data['subscription_id']).to eq Payment::BraintreeSubscription.last.subscription_id
              expect(form_data['transaction_id']).to eq Payment::BraintreeTransaction.last.transaction_id
            end

            it 'passes PYPL as card_num to queue' do
              subject
              expect( ChampaignQueue ).to have_received(:push).with(a_hash_including(
                params: a_hash_including( order: a_hash_including(card_num: 'PYPL') )
              ))
            end

            it 'responds successfully with subscription_id' do
              subject
              subscription_id = Payment::BraintreeSubscription.last.subscription_id
              expect(response.status).to eq 200
              expect(response.body).to eq({ success: true, subscription_id: subscription_id }.to_json)
            end

          end
        end
      end

      context 'when Member is new' do

        context 'when BraintreeCustomer is new' do

          context 'with basic params' do

            # we're using the same casette as above anyway, so we're only running specs
            # relevant to the new member

            let(:amount) { 813.20 } # to avoid duplicate donations recording specs
            let(:params) { basic_params.merge(user: user_params, amount: amount) }

            subject do
              VCR.use_cassette("subscription success basic new customer") do
                post api_braintree_transaction_path(page.id), params
              end
            end

            it 'increments redis counters' do
              expect(Analytics::Page).to receive(:increment).with(page.id, new_member: true)
              subject
            end

            it "creates an Action associated with the Page and Member" do
              expect{ subject }.to change{ Action.count }.by 1
              expect(Action.last.page).to eq page
              expect(Action.last.member).to eq Member.last
            end

            it "leaves a cookie with the member_id" do
              expect(cookies['member_id']).to eq nil
              subject

              # we can't access signed cookies in request specs, so check for hashed value
              expect(cookies['member_id']).not_to eq nil
              expect(cookies['member_id'].length).to be > 20
            end

            it "populates the Member’s fields with form data" do
              expect{ subject }.to change{ Member.count }.by 1
              member = Member.last
              expect(member.first_name).to eq 'Bernie'
              expect(member.last_name).to eq 'Sanders'
              expect(member.postal).to eq '11225'
            end

            it 'responds successfully with subscription_id' do
              subject
              subscription_id = Payment::BraintreeSubscription.last.subscription_id
              expect(response.status).to eq 200
              expect(response.body).to eq({ success: true, subscription_id: subscription_id }.to_json)
            end
          end
        end
      end
    end
  end

  describe "storing multiple payment method tokens" do

    context "existing customer" do
      let(:basic_params) do
        {
            currency: 'EUR',
            payment_method_nonce: 'fake-valid-mastercard-nonce',
            recurring: false
        }
      end

      let(:params) { basic_params.merge(user: user_params, amount: 5) }

      subject do
        VCR.use_cassette("transaction_existing_customer_storing_multiple_tokens") do
          post api_braintree_transaction_path(page.id), params
        end
      end

      let!(:member) { create :member, email: user_params[:email], postal: nil }
      let!(:customer) {
        create :payment_braintree_customer, :with_payment_method_tokens,
               member: member,
               customer_id: 'test',
               card_last_4: '4843',
               payment_methods: 3
      }
      it "supports storing multiple braintree payment method tokens" do
        original_token = customer.default_payment_method_token
        expect( customer.braintree_payment_method_tokens.length ).to eq 3
        expect( customer.braintree_payment_method_tokens ).to include(original_token)
        expect{ subject }.to change{ Payment::BraintreeCustomer.count }.by 0
        customer.reload
        expect( customer.braintree_payment_method_tokens.length ).to eq 4
        expect( customer.default_payment_method_token ).not_to eq original_token
        expect( customer.braintree_payment_method_tokens ).to include(original_token, customer.default_payment_method_token)
      end

      it "does not duplicate payment method token if the same token is used" do
        original_token = customer.default_payment_method_token
        expect( customer.braintree_payment_method_tokens.length ).to eq 3
        expect( customer.braintree_payment_method_tokens ).to include(original_token)
        expect{ subject }.to change{ Payment::BraintreeCustomer.count }.by 0
        customer.reload
        expect( customer.braintree_payment_method_tokens.length ).to eq 4
        expect( customer.default_payment_method_token ).not_to eq original_token
        expect( customer.braintree_payment_method_tokens ).to include(original_token, customer.default_payment_method_token)
        new_token = customer.default_payment_method_token
        VCR.use_cassette("transaction_existing_customer_storing_multiple_tokens_second_request") do
          post api_braintree_transaction_path(page.id), params
        end
        customer.reload
        # THIS FAILS - If the customer uses the same nonce again, a new token gets created in the vault - we have
        # no functionality for using the existing token right now.
        expect( customer.braintree_payment_method_tokens.length ).to eq 4
        expect( customer.default_payment_method_token ).to eq new_token
        expect( Payment::BraintreeTransaction.where(payment_method_token_id: new_token.id).length ).to eq 2
      end
    end

    context "new customer" do
      let(:params) { basic_params.merge(user: user_params, amount: amount) }
      subject do
        VCR.use_cassette("transaction_existing_customer_storing_multiple_tokens") do
          post api_braintree_transaction_path(page.id), params
        end
      end

    end
  end

  describe "fetching a token" do
    it 'gets a client token' do
      VCR.use_cassette("braintree_client_token") do
        expect{ get api_braintree_token_path }.not_to raise_error

        body = JSON.parse(response.body).with_indifferent_access
        expect(body).to have_key(:token)
        expect(body[:token].to_s).to match a_string_matching(/[a-zA-Z0-9=]{5,5000}/)
      end
    end
  end

end

