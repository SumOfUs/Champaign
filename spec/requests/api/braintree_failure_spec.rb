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

describe "Braintree API" do

  let(:page) { create(:page, title: 'The more money we come across, the more problems we see') }
  let(:form) { create(:form) }
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
      amount:     '2000.00', # amount is hooked into BT to cause failure
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
        describe "when BraintreeCustomer is new" do
          describe "with basic params" do
            subject do
              VCR.use_cassette("transaction processor declined") do
                post api_braintree_transaction_path(page.id), params
              end
            end
            include_examples "creates nothing"
            it "passes the params to braintree"
            it "does not update the member"
            it "serializes errors in JSON"
            it "creates a Transaction associated with the page storing relevant info"
          end
          describe "with Paypal" do
            # include_examples "creates nothing"
            it "does not update the member"
            it "creates a Transaction associated with the page storing relevant info"
            it "serializes errors in JSON"
          end
        end
        describe "when BraintreeCustomer exists" do
          describe "with Paypal" do
            # include_examples "creates nothing"
            it "does not update the member"
            it "passes the params to braintree"
            it "does not update the BraintreeCustomer in the database"
            it "creates a Transaction associated with the page storing relevant info"
            it "serializes errors in JSON"
          end
          describe "with Paypal" do
            # include_examples "creates nothing"
            it "does not update the member"
            it "creates a Transaction associated with the page storing relevant info"
            it "serializes errors in JSON"
          end
        end
      end
      describe "when Member is new" do
        describe "when BraintreeCustomer is new" do
          describe "with basic params" do
            # include_examples "creates nothing"
            it "responds with 422 and errors"
          end
        end
      end
    end
    describe "making a subscription" do
      describe "when Member exists" do
        describe "when BraintreeCustomer exists" do
          describe "when it fails updating the Customer" do
            # include_examples "creates nothing"
            it "does not update the customer"
            it "does not create a Transaction"
            it "serializes errors in JSON"
          end
          describe "when it fails creating the PaymentMethod" do
            # include_examples "creates nothing"
            it "does not update the customer"
            it "does not create a Transaction"
            it "serializes errors in JSON"
          end
          describe "when it fails creating the Subscription" do
            # include_examples "creates nothing"
            it "does not update the customer"
            it "does not create a Transaction"
            it "serializes errors in JSON"
          end
        end
        describe "when BraintreeCustomer is new" do
          describe "when it fails creating the Customer" do
            # include_examples "creates nothing"
            it "does not create a Transaction"
            it "serializes errors in JSON"
          end
          describe "when it fails creating the Subscription" do
            # include_examples "creates nothing"
            it "does not create a Transaction"
            it "serializes errors in JSON"
          end
        end
      end
      describe "when Member is new" do
        describe "when BraintreeCustomer is new" do
          describe "with basic params" do
            # include_examples "creates nothing"
            it "serializes errors in JSON"
          end
        end
      end
    end
  end
end
