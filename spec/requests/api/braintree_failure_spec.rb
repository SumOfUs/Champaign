require 'rails_helper'

shared_examples "creates nothing" do
  it "does not create an Action" do
    expect{ subject }.not_to change{ Action.count }
  end
  it "does not create a Member" do
    expect{ subject }.not_to change{ Member.count }
  end
  it "does not create a BraintreeCustomer" do
    expect{ subject }.not_to change{ Payment::BraintreeCustomer.count }
  end
  it "does not create a BraintreeSubscription" do
    expect{ subject }.not_to change{ Payment::BraintreeSubscription.count }
  end
  it "does not increment the Page's action count" do
    expect{ subject }.not_to change{ page.action_count }
  end
  it "does not leave a cookie" do
    subject
    expect(cookies['member_id']).to eq nil
  end
  it "does not post to the queue" do
    subject
    expect( ChampaignQueue ).not_to have_received(:push)
  end
  it "responds with 422" do
    subject
    expect( response.status ).to eq 422
  end
end
shared_examples "processor errors" do
  it "serializes processor errors in JSON" do
    subject
    errors = {success: false, errors: [{declined: true, code: "2002", message: "Limit Exceeded"}]}
    expect( response.body ).to eq errors.to_json
  end
end

describe "Braintree API" do

  let(:page) { create(:page, title: 'The more money we come across, the more problems we see') }
  let(:form) { create(:form) }
  let(:token_format) { /[a-z0-9]{1,36}/i }
  let(:user) do
    {
      form_id:  form.id,
      name:     'bob fischer',
      email:    'bob@example.com',
      postal:   '12345',
      address1: 'Lynda Vista',
      country:  'US'
    }
  end

  let(:params) do
    {
      currency:   'EUR',
      amount:     '2002.00', # triggers credit limit exceeded
      recurring:  false,
      payment_method_nonce: 'fake-valid-nonce',
      user: user
    }
  end

  before :each do
    allow(ChampaignQueue).to receive(:push)
  end

  describe "unsuccessfuly" do
    describe "making a transaction" do
      describe "when Member exists" do

        let!(:member) { create :member, email: user[:email], postal: nil }

        describe "when BraintreeCustomer is new" do
          describe "with basic params" do
            subject do
              VCR.use_cassette("transaction processor declined") do
                post api_braintree_transaction_path(page.id), params
              end
            end

            include_examples "creates nothing"
            include_examples "processor errors"

            it "does not update the member" do
              expect{ subject }.not_to change{ member.reload }
            end

            it "creates a Transaction associated with the page storing relevant info" do
              expect{ subject }.to change{ Payment::BraintreeTransaction.count }.by 1
              transaction = Payment::BraintreeTransaction.last
              expect(transaction.page).to eq page
              expect(transaction.amount).to eq 2002
              expect(transaction.currency).to eq 'EUR'
              expect(transaction.merchant_account_id).to eq 'EUR'
              expect(transaction.payment_instrument_type).to eq 'credit_card'
              expect(transaction.transaction_type).to eq 'sale'
              expect(transaction.customer_id).to eq nil
              expect(transaction.status).to eq 'failure'
              expect(transaction.processor_response_code).to eq '2002'
              expect(transaction.payment_method_token).to eq nil
              expect(transaction.transaction_id).to match a_string_matching(token_format)
            end
          end

          describe "with Paypal" do
            let(:paypal_params) do
              params.merge(payment_method_nonce: 'fake-paypal-future-nonce', merchant_account_id: 'EUR')
            end

            subject do
              VCR.use_cassette('transaction paypal processor declined') do
                post api_braintree_transaction_path(page.id), paypal_params
              end
            end

            include_examples 'creates nothing'
            include_examples "processor errors"

            it "does not update the member" do
              expect{ subject }.not_to change{ member.reload }
            end
            it "creates a Transaction associated with the page storing relevant info" do
              expect{ subject }.to change{ Payment::BraintreeTransaction.count }.by 1
              transaction = Payment::BraintreeTransaction.last
              expect(transaction.page).to eq page
              expect(transaction.amount).to eq 2002
              expect(transaction.currency).to eq 'EUR'
              expect(transaction.merchant_account_id).to eq 'EUR'
              expect(transaction.payment_instrument_type).to eq 'paypal_account'
              expect(transaction.transaction_type).to eq 'sale'
              expect(transaction.customer_id).to eq nil
              expect(transaction.status).to eq 'failure'
              expect(transaction.processor_response_code).to eq '2002'
              expect(transaction.payment_method_token).to eq nil
              expect(transaction.transaction_id).to match a_string_matching(token_format)
            end
          end
        end
        describe "when BraintreeCustomer exists" do
          describe "with Paypal" do
            let(:paypal_params) {
              params.merge(payment_method_nonce: 'fake-paypal-future-nonce', merchant_account_id: 'EUR')
            }
            let!(:braintree_customer) {
              create(:payment_braintree_customer)
            }

            subject do
              VCR.use_cassette('transaction paypal processor declined') do
                post api_braintree_transaction_path(page.id), paypal_params
              end
            end

            include_examples "creates nothing"
            include_examples "processor errors"

            it "does not update the member" do
              expect{ subject }.not_to change{ member.reload }
            end
            it "does not update the BraintreeCustomer in the database" do
              expect{ subject }.not_to change{ braintree_customer.reload }
            end
            it "creates a Transaction associated with the page storing relevant info" do
              expect{ subject }.to change{ Payment::BraintreeTransaction.count }.by 1
              transaction = Payment::BraintreeTransaction.last
              expect(transaction.page).to eq page
              expect(transaction.amount).to eq 2002
              expect(transaction.currency).to eq 'EUR'
              expect(transaction.merchant_account_id).to eq 'EUR'
              expect(transaction.payment_instrument_type).to eq 'paypal_account'
              expect(transaction.transaction_type).to eq 'sale'
              expect(transaction.customer_id).to eq nil
              expect(transaction.status).to eq 'failure'
              expect(transaction.processor_response_code).to eq '2002'
              expect(transaction.payment_method_token).to eq nil
              expect(transaction.transaction_id).to match a_string_matching(token_format)
            end
          end
        end
      end
      describe "when Member is new" do
        describe "when BraintreeCustomer is new" do
          describe "with basic params" do

            subject do
              VCR.use_cassette("transaction processor declined") do
                post api_braintree_transaction_path(page.id), params
              end
            end

            include_examples "creates nothing"
            include_examples "processor errors"
          end

          describe "with invalid currency" do
            before do
              params[:currency] = 'JPN'
            end

            it 'raises relevant error' do
             expect{
                VCR.use_cassette("transaction not handled currency") do
                  post api_braintree_transaction_path(page.id), params
                end
              }.to raise_error(PaymentProcessor::Exceptions::InvalidCurrency)
            end
          end
        end
      end
    end
    describe "making a subscription" do

      let(:subscription_params){ params.merge(recurring: true) }

      describe "when Member exists" do

        let!(:member) { create :member, email: user[:email], postal: nil }

        describe "when BraintreeCustomer exists" do

          let!(:customer) { create :payment_braintree_customer, member: member, customer_id: 'test', card_last_4: '4843' }

          describe "when it fails updating the Customer" do
            let(:failing_params) {
              subscription_params.merge(user: user.merge(name: 'John Johnny '*60, amount: 12))
            }

            subject do
              VCR.use_cassette('customer update failure') do
                post api_braintree_transaction_path(page.id), failing_params
              end
            end

            include_examples "creates nothing"

            it "does not update the customer" do
              expect{ subject }.not_to change{ customer.reload }
            end

            it "does not create a Transaction" do
              expect{ subject }.not_to change{ Payment::BraintreeTransaction.count }
            end

            it "serializes errors in JSON" do
              subject
              errors = {success: false, errors: [{code: "81608", attribute: "first_name", message: "First name is too long."}, {code: "81613", attribute: "last_name", message: "Last name is too long."}]}
              expect( response.body ).to eq errors.to_json
            end
          end

          describe "when it fails creating the PaymentMethod" do
            let(:failing_params) {
              subscription_params.merge(user: user.merge(street_address: 'Del colegio Verde Sonrisa, una cuadra arriba, una cuadra al sur, la casa amarilla en la esquina, numero 166 '*3, amount: 12))
            }

            subject do
              VCR.use_cassette('payment method create failure') do
                post api_braintree_transaction_path(page.id), failing_params
              end
            end

            include_examples "creates nothing"

            it "does not update the customer" do
              expect{ subject }.not_to change{ customer.reload }
            end

            it "does not create a Transaction" do
              expect{ subject }.not_to change{ Payment::BraintreeTransaction.count }
            end

            it "serializes errors in JSON" do
              subject
              errors = {success: false, errors: [{code: "81812", attribute: "street_address", message: "Street address is too long."}]}
              expect( response.body ).to eq errors.to_json
            end
          end
          describe "when it fails creating the Subscription" do

            subject do
              VCR.use_cassette('subscription create failure with existing customer') do
                post api_braintree_transaction_path(page.id), subscription_params
              end
            end

            include_examples "creates nothing"

            it "does not update the customer" do
              expect{ subject }.not_to change{ customer.reload }
            end

            it "does not create a Transaction" do
              expect{ subject }.not_to change{ Payment::BraintreeTransaction.count }
            end

            include_examples "processor errors"
          end
        end
        describe "when BraintreeCustomer is new" do
          describe "when it fails creating the Customer" do
            let(:failing_params) {
              subscription_params.merge(user: user.merge(name: 'John Johnny '*60, amount: 12))
            }

            subject do
              VCR.use_cassette('customer create failure') do
                post api_braintree_transaction_path(page.id), failing_params
              end
            end

            include_examples "creates nothing"

            it "does not create a Transaction" do
              expect{ subject }.not_to change{ Payment::BraintreeTransaction.count }
            end

            it "serializes errors in JSON" do
              subject
              errors = {success: false, errors: [{code: "81608", attribute: "first_name", message: "First name is too long."}, {code: "81613", attribute: "last_name", message: "Last name is too long."}, {code: "81805", attribute: "first_name", message: "First name is too long."}, {code: "81806", attribute: "last_name", message: "Last name is too long."}]}
              expect( response.body ).to eq errors.to_json
            end
          end

          describe "when it fails creating the Subscription" do

            subject do
              VCR.use_cassette('subscription create failure') do
                post api_braintree_transaction_path(page.id), subscription_params
              end
            end

            include_examples "creates nothing"
            include_examples "processor errors"

            it "does not create a Transaction" do
              expect{ subject }.not_to change{ Payment::BraintreeTransaction.count }
            end
          end
        end
      end
      describe "when Member is new" do
        describe "when BraintreeCustomer is new" do
          describe "when it fails creating the Customer" do
            let(:failing_params) {
              subscription_params.merge(user: user.merge(name: 'John Johnny '*60, amount: 12))
            }

            subject do
              VCR.use_cassette('customer create failure') do
                post api_braintree_transaction_path(page.id), failing_params
              end
            end

            include_examples "creates nothing"

            it "does not create a Transaction" do
              expect{ subject }.not_to change{ Payment::BraintreeTransaction.count }
            end

            it "serializes errors in JSON" do
              subject
              errors = {success: false, errors: [{code: "81608", attribute: "first_name", message: "First name is too long."}, {code: "81613", attribute: "last_name", message: "Last name is too long."}, {code: "81805", attribute: "first_name", message: "First name is too long."}, {code: "81806", attribute: "last_name", message: "Last name is too long."}]}
              expect( response.body ).to eq errors.to_json
            end
          end

          describe "when it fails creating the Subscription" do

            subject do
              VCR.use_cassette('subscription create failure') do
                post api_braintree_transaction_path(page.id), subscription_params
              end
            end

            include_examples "creates nothing"
            include_examples "processor errors"

            it "does not create a Transaction" do
              expect{ subject }.not_to change{ Payment::BraintreeTransaction.count }
            end
          end
        end
      end
    end
  end
end
