# coding: utf-8
# frozen_string_literal: true
require 'rails_helper'

describe 'Express Donation' do
  include Requests::RequestHelpers
  let!(:page) { create(:page, slug: 'hello-world', title: 'Hello World') }
  let(:form)  { create(:form) }

  let(:member)          { create(:member, email: 'test@example.com') }
  let(:customer)        { create(:payment_braintree_customer, member: member) }
  let!(:payment_method) { create(:payment_braintree_payment_method, customer: customer, token: '6vg2vw') }

  before do
    allow(ChampaignQueue).to receive(:push)
  end

  describe 'making multiple transactions on the same page' do
    subject do
      body = {
        payment: {
          amount: 2.00,
          payment_method_id: payment_method.id,
          currency: 'GBP',
          recurring: false
        },
        user: {
          form_id: form.id,
          email:   'test@example.com',
          name:    'John Doe'
        },
        page_id: page.id
      }
      post api_payment_braintree_one_click_path(page.id), body
      post api_payment_braintree_one_click_path(page.id), body
    end

    it 'creates an action and a transaction for each payment' do
      VCR.use_cassette('express_donation_multiple_transactions') do
        expect(Action.all.count).to eq 0
        expect(Payment::Braintree::Transaction.all.count).to eq 0
        subject
        expect(Action.all.count).to eq 2
        expect(Payment::Braintree::Transaction.all.count).to eq 2
      end
    end
  end

  describe 'subscription' do
    before do
      VCR.use_cassette('braintree_express_donation_subscription') do
        body = {
          payment: {
            amount: 2.00,
            payment_method_id: payment_method.id,
            currency: 'GBP',
            recurring: true
          },
          user: {
            form_id: form.id,
            email:   'test@example.com',
            name:    'John Doe'
          },
          page_id: page.id
        }

        post api_payment_braintree_one_click_path(page.id), body
      end
    end

    it 'sets donor status to "recurring_donor"' do
      expect(member.reload.donor_status).to eq('recurring_donor')
    end

    describe 'local record' do
      it 'creates action' do
        action = page.actions.first

        expect(
          action.form_data.deep_symbolize_keys
        ).to include(form_id: form.id.to_s)

        expect(
          Action.first.member.attributes.symbolize_keys
        ).to include(email: 'test@example.com')
      end

      it 'creates subscription' do
        subscription = Payment::Braintree::Subscription.last

        expected_attributes = {
          page_id: page.id,
          subscription_id: /[a-z0-9]{6}/,
          payment_method_id: payment_method.id
        }

        expect(subscription.reload.action).to be_an Action
        expect(subscription.attributes.symbolize_keys)
          .to include(expected_attributes)
      end
    end
  end

  context 'Braintree Error responses' do
    describe 'transaction' do
      before do
        VCR.use_cassette('express_donations_invalid_payment_method') do
          result = Braintree::Transaction.sale(
            payment_method_nonce: 'fake-processor-declined-visa-nonce'
          )

          allow_any_instance_of(PaymentProcessor::Braintree::OneClick).to(
            receive(:run).and_return(result)
          )

          body = {
            payment: {
              amount: 2.00,
              payment_method_id: payment_method.id,
              currency: 'GBP',
              recurring: false
            },
            user: {
              form_id: form.id,
              email:   'test@example.com',
              name:    'John Doe'
            },
            page_id: page.id
          }

          post api_payment_braintree_one_click_path(page.id), body
        end
      end

      it 'responds with a 422 status code' do
        expect(response.status).to eq(422)
      end

      it 'body contains errors serialised' do
        expect(json_hash).to include('errors')
        expect(json_hash).to satisfy { |v| !v['errors'].empty? }
      end

      it 'body contains an error message' do
        expect(json_hash).to include('message')
      end

      it 'body contains braintree params' do
        expect(json_hash).to include('params')
      end
    end
  end

  describe 'transaction' do
    before do
      allow(Braintree::Transaction).to receive(:sale).and_call_original
      VCR.use_cassette('braintree_express_donation') do
        body = {
          payment: {
            amount: 2.00,
            payment_method_id: payment_method.id,
            currency: 'gbp',
            recurring: false
          },
          user: {
            form_id: form.id,
            email:   'test@example.com',
            name:    'John Doe'
          },
          page_id: page.id
        }

        post api_payment_braintree_one_click_path(page.id), body
      end
    end

    describe 'local record' do
      it 'creates action' do
        action = page.actions.first

        expect(
          action.form_data.deep_symbolize_keys
        ).to include(form_id: form.id.to_s)

        expect(
          Action.first.member.attributes.symbolize_keys
        ).to include(email: 'test@example.com')
      end

      it 'creates transaction' do
        expected_attributes = {
          transaction_type: 'sale',
          transaction_id:   /[a-z0-9]{8}/,
          page_id: page.id
        }

        transaction = payment_method.transactions.first.attributes.symbolize_keys
        expect(transaction).to include(expected_attributes)
      end

      it 'sets donor status to "donor"' do
        expect(member.reload.donor_status).to eq('donor')
      end
    end

    it 'creates transaction on braintree' do
      expect(payment_method.customer).to eq(customer)
    end

    it 'posts a donation to the queue with action_express_donation custom field' do
      expect(ChampaignQueue).to have_received(:push)
        .with(
          type: 'donation',
          payment_provider: 'braintree',
          params: {
            donationpage: {
              name: 'hello-world-donation',
              payment_account: 'Braintree GBP'
            },
            order: hash_including(amount: '2.0',
                                  card_num: '1234',
                                  exp_date_month: '12',
                                  exp_date_year: '2050'),
            action: hash_including(fields: hash_including(action_express_donation: 1)),
            user: hash_including(first_name: 'John',
                                 last_name: 'Doe',
                                 email: 'test@example.com',
                                 user_express_cookie: 1,
                                 user_express_account: 0)
          },
          meta: hash_including({})
        )
    end

    it 'submits the transaction for settlement' do
      expect(Braintree::Transaction).to have_received(:sale).with(hash_including(
        options: { submit_for_settlement: true }
      ))
    end

    it 'calls the Braintree API with the merchant_account_id' do
      expect(Braintree::Transaction).to have_received(:sale).with(hash_including(
        merchant_account_id: 'GBP'
      ))
    end
  end
end
