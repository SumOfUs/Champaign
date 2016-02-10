require 'rails_helper'

describe "Braintree API" do

  let(:page) { create(:page, title: 'Cash rules everything around me') }
  let(:form) { create(:form) }

  before :each do
    allow(ChampaignQueue).to receive(:push)
  end

  describe 'making a transaction' do
    describe 'successfully' do

      let(:basic_params) do
        {
          currency: 'EUR',
          payment_method_nonce: 'fake-valid-nonce',
          amount: 27.25,
          recurring: false
        }
      end
      let(:user_params) do
        {
          form_id: form.id,
          name: "Bernie Sanders",
          email: "itsme@feelthebern.org",
          postal: "11225",
          address1: '25 Elm Drive',
          country: "US"
        }
      end

      context 'when Member exists' do

        let!(:member) { create :member, email: user_params[:email], postal: nil }

        context 'when BraintreeCustomer exists' do

          let!(:customer) { create :payment_braintree_customer, member: member, customer_id: 'test' }

          context 'with basic params' do

            let(:params) { basic_params.merge(user: user_params) }
            subject do
              VCR.use_cassette("transaction success basic existing customer") do
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
              expect(form_data['amount']).to eq '27.25'
              expect(form_data['currency']).to eq 'EUR'
              expect(form_data['transaction_id']).to eq Payment::BraintreeTransaction.last.transaction_id
            end

            it "creates a Transaction associated with the page storing relevant info" do
              expect{ subject }.to change{ Payment::BraintreeTransaction.count }.by 1
              transaction = Payment::BraintreeTransaction.last

              expect(transaction.page).to eq page
              expect(transaction.amount).to eq '27.25'
              expect(transaction.currency).to eq 'EUR'
              expect(transaction.merchant_account_id).to eq 'EUR'
              expect(transaction.payment_instrument_type).to eq 'credit_card'
              expect(transaction.transaction_type).to eq 'sale'
              expect(transaction.customer_id).to eq customer.customer_id
              expect(transaction.status).to eq 'success'

              expect(transaction.payment_method_token).not_to be_blank
              expect(transaction.transaction_id).not_to be_blank
            end

            it "updates Payment::BraintreeCustomer including last four for credit card" do
              previous_last_4 = customer.card_last_4
              expect{ subject }.to change{ Payment::BraintreeCustomer.count }.by 0
              expect( customer.reload.card_last_4 ).not_to eq previous_last_4
            end

            it "posts donation action to queue with key data" do
              subject
              expect( ChampaignQueue ).to have_received(:push).with({
                type: "donation",
                params: {
                  donationpage: {
                    name: "cash-rules-everything-around-me-donation",
                    payment_account: "Default Import Stub"
                  },
                  order: {
                    amount: "27.25",
                    card_num: "1881",
                    card_code: "007",
                    exp_date_month: "12",
                    exp_date_year: "2020",
                    currency: "EUR"
                  },
                  user: {
                    email: "itsme@feelthebern.org",
                    country: "US",
                    postal: "11225",
                    address1: '25 Elm Drive',
                    first_name: 'Bernie',
                    last_name: 'Sanders'
                  }
                }
              })
            end

            it "increments action count on page" do
              expect{ subject }.to change{ page.reload.action_count }.by 1
            end

            it "passes the params to braintree" do
              allow(Braintree::Transaction).to receive(:sale).and_call_original
              subject
              expect(Braintree::Transaction).to have_received(:sale).with({
                amount: 27.25,
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
          end

          context 'with Paypal' do

            let(:params) { basic_params.merge(user: user_params, payment_method_nonce: 'fake-paypal-future-nonce') }

            subject do
              VCR.use_cassette("transaction success paypal existing customer") do
                post api_braintree_transaction_path(page.id), params
              end
            end

            it "creates a Transaction associated with the page storing relevant info" do
              expect{ subject }.to change{ Payment::BraintreeTransaction.count }.by 1
              transaction = Payment::BraintreeTransaction.last

              expect(transaction.page).to eq page
              expect(transaction.amount).to eq '27.25'
              expect(transaction.currency).to eq 'EUR'
              expect(transaction.merchant_account_id).to eq 'EUR'
              expect(transaction.payment_instrument_type).to eq 'paypal_account'
              expect(transaction.transaction_type).to eq 'sale'
              expect(transaction.customer_id).to eq customer.customer_id
              expect(transaction.status).to eq 'success'

              expect(transaction.payment_method_token).not_to be_blank
              expect(transaction.transaction_id).not_to be_blank
            end

            it "does not change Payment::BraintreeCustomer" do
              expect{ subject }.to change{ Payment::BraintreeCustomer.count }.by 0
              expect( customer ).to eq Payment::BraintreeCustomer.find(customer.id)
            end

            it "stores PYPL as card_num on the Action" do
              expect{ subject }.to change{ Action.count }.by 1
              form_data = Action.last.form_data
              expect(form_data['card_num']).to eq 'PYPL'
              expect(form_data['is_subscription']).to eq false
              expect(form_data['amount']).to eq '27.25'
              expect(form_data['currency']).to eq 'EUR'
              expect(form_data['transaction_id']).to eq Payment::BraintreeTransaction.last.transaction_id
            end

            it 'passes PYPL as card_num to queue' do
              subject
              expect( ChampaignQueue ).to have_received(:push).with(a_hash_including(
                params: a_hash_including( order: a_hash_including(card_num: 'PYPL') )
              ))
            end

          end
        end

        context 'when BraintreeCustomer is new' do

          context 'with basic params' do

            let(:params) { basic_params.merge(user: user_params) }
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
              expect(form_data['amount']).to eq '27.25'
              expect(form_data['currency']).to eq 'EUR'
              expect(form_data['transaction_id']).to eq Payment::BraintreeTransaction.last.transaction_id
            end

            it "creates a Transaction associated with the page storing relevant info" do
              expect{ subject }.to change{ Payment::BraintreeTransaction.count }.by 1
              transaction = Payment::BraintreeTransaction.last

              expect(transaction.page).to eq page
              expect(transaction.amount).to eq '27.25'
              expect(transaction.currency).to eq 'EUR'
              expect(transaction.merchant_account_id).to eq 'EUR'
              expect(transaction.payment_instrument_type).to eq 'credit_card'
              expect(transaction.transaction_type).to eq 'sale'
              expect(transaction.customer_id).to eq Payment::BraintreeCustomer.last.customer_id
              expect(transaction.status).to eq 'success'

              expect(transaction.payment_method_token).not_to be_blank
              expect(transaction.transaction_id).not_to be_blank
            end

            it "creates new Payment::BraintreeCustomer including customer_id and last four for credit card" do
              expect{ subject }.to change{ Payment::BraintreeCustomer.count }.by 1
              customer = Payment::BraintreeCustomer.last
              expect( customer.customer_id ).not_to be_blank
              expect( customer.card_last_4 ).to eq '1881'
            end

            it "posts donation action to queue with key data" do
              subject
              expect( ChampaignQueue ).to have_received(:push).with({
                type: "donation",
                params: {
                  donationpage: {
                    name: "cash-rules-everything-around-me-donation",
                    payment_account: "Default Import Stub"
                  },
                  order: {
                    amount: "27.25",
                    card_num: "1881",
                    card_code: "007",
                    exp_date_month: "12",
                    exp_date_year: "2020",
                    currency: "EUR"
                  },
                  user: {
                    email: "itsme@feelthebern.org",
                    country: "US",
                    postal: "11225",
                    address1: '25 Elm Drive',
                    first_name: 'Bernie',
                    last_name: 'Sanders'
                  }
                }
              })
            end

            it "increments action count on page" do
              expect{ subject }.to change{ page.reload.action_count }.by 1
            end

            it "passes the params to braintree" do
              allow(Braintree::Transaction).to receive(:sale).and_call_original
              subject
              expect(Braintree::Transaction).to have_received(:sale).with({
                amount: 27.25,
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
          end

          context 'with Paypal' do

            let(:params) { basic_params.merge(user: user_params, payment_method_nonce: 'fake-paypal-future-nonce') }

            subject do
              VCR.use_cassette("transaction success paypal new customer") do
                post api_braintree_transaction_path(page.id), params
              end
            end

            it "creates a Transaction associated with the page storing relevant info" do
              expect{ subject }.to change{ Payment::BraintreeTransaction.count }.by 1
              transaction = Payment::BraintreeTransaction.last

              expect(transaction.page).to eq page
              expect(transaction.amount).to eq '27.25'
              expect(transaction.currency).to eq 'EUR'
              expect(transaction.merchant_account_id).to eq 'EUR'
              expect(transaction.payment_instrument_type).to eq 'paypal_account'
              expect(transaction.transaction_type).to eq 'sale'
              expect(transaction.customer_id).to eq Payment::BraintreeCustomer.last.customer_id
              expect(transaction.status).to eq 'success'

              expect(transaction.payment_method_token).not_to be_blank
              expect(transaction.transaction_id).not_to be_blank
            end

            it "creates a Payment::BraintreeCustomer with customer_id and PYPL for last 4" do
              expect{ subject }.to change{ Payment::BraintreeCustomer.count }.by 1
              customer = Payment::BraintreeCustomer.last
              expect(customer.customer_id).not_to be_blank
              expect(customer.card_last_4).to eq 'PYPL'
            end

            it "stores PYPL as card_num on the Action" do
              expect{ subject }.to change{ Action.count }.by 1
              form_data = Action.last.form_data
              expect(form_data['card_num']).to eq 'PYPL'
              expect(form_data['is_subscription']).to eq false
              expect(form_data['amount']).to eq '27.25'
              expect(form_data['currency']).to eq 'EUR'
              expect(form_data['transaction_id']).to eq Payment::BraintreeTransaction.last.transaction_id
            end

            it 'passes PYPL as card_num to queue' do
              subject
              expect( ChampaignQueue ).to have_received(:push).with(a_hash_including(
                params: a_hash_including( order: a_hash_including(card_num: 'PYPL') )
              ))
            end

          end
        end
      end

      context 'when Member is new' do
        context 'when BraintreeCustomer is new' do

        end
      end
    end
  end
end


