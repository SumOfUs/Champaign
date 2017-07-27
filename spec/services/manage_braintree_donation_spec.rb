# frozen_string_literal: true

require 'rails_helper'
describe ManageBraintreeDonation do
  let(:braintree_arguments) do
    {
      amount: '100.00',
      merchant_account_id: 'GBP',
      payment_method_nonce: payment_nonce,
      options: {
        store_in_vault: true,
        submit_for_settlement: true
      }
    }
  end

  let(:transaction) do
    VCR.use_cassette('manage braintree donation transaction') do
      Braintree::Transaction.sale(braintree_arguments)
    end
  end

  let(:paypal_transaction) do
    VCR.use_cassette('manage braintree donation paypal transaction') do
      Braintree::Transaction.sale(braintree_arguments)
    end
  end

  let(:subscription) do
    VCR.use_cassette('manage braintree donation subscription') do
      Braintree::Subscription.create(
        price: '1.00',
        payment_method_token:  transaction.transaction.credit_card_details.token,
        merchant_account_id: 'EUR',
        plan_id: 'EUR'
      )
    end
  end

  let(:payment_nonce) { 'fake-valid-nonce' }
  let(:page) { create(:page, slug: 'foo-bar') }

  let(:params) do
    { page_id: page.id, country: 'BO', email: 'foo@example.com', name: 'Bob Murphy' }
  end

  subject do
    ManageBraintreeDonation.create(params: params,
                                   braintree_result: transaction,
                                   is_subscription: false)
  end

  before do
    allow(ChampaignQueue).to receive(:push)
  end

  it 'creates an action' do
    expect do
      subject
    end.to change { Action.count }.by(1)
  end

  describe 'action' do
    let(:action) { Action.first }

    let(:expected_form_data) do
      {
        name:    'Bob Murphy',
        email:   'foo@example.com',
        country: 'BO',
        page_id:  page.id,
        card_num: '1881',
        currency: /^\w{3}$/,
        transaction_id: /^[a-z0-9]*$/
      }
    end

    describe 'Transaction' do
      context 'with existing member' do
        let!(:member) { create(:member, email: 'foo@example.com') }

        it 'subscribes member' do
          subject
          expect(action.subscribed_member).to eq(false)
        end
      end
    end

    describe 'Credit Card Transaction' do
      before { subject }

      it 'pushes to queue' do
        expected = {
          type: 'donation'
        }
        expect(ChampaignQueue).to have_received(:push)
          .with(hash_including(expected), group_id: /action:\d+/)
      end

      it 'is marked as a donation' do
        expect(action.donation?).to be true
      end

      context 'without existing member' do
        it 'subscribes member' do
          expect(action.subscribed_member).to eq(true)
        end
      end

      describe 'form_data' do
        it 'includes general donation data' do
          expect(action.form_data.symbolize_keys).to include(expected_form_data)
        end

        it 'includes amount' do
          expect(action.form_data['amount']).to eq('100.0')
        end

        it 'does not include subscription id' do
          expect(action.form_data).not_to include('subscription_id' => /[a-z0-9]*$/)
        end
      end
    end

    describe 'Subscription' do
      subject do
        ManageBraintreeDonation.create(params: params,
                                       braintree_result: subscription,
                                       is_subscription: false)
      end

      describe 'action' do
        let(:action) { Action.first }
        before { subject }

        it 'is marked as a donation' do
          expect(action.donation?).to be true
        end

        describe 'form_data' do
          it 'includes general donation data' do
            expect(action.form_data.symbolize_keys).to include(expected_form_data)
          end

          it 'includes amount' do
            expect(action.form_data['amount']).to eq('1.0')
          end

          it 'includes subscription id' do
            expect(action.form_data).to include('subscription_id' => /[a-z0-9]*$/)
          end
        end
      end
    end
  end

  describe 'PayPal Transaction' do
    let(:payment_nonce) { 'fake-paypal-future-nonce' }

    subject do
      ManageBraintreeDonation.create(params: params,
                                     braintree_result: paypal_transaction,
                                     is_subscription: false)
    end

    describe 'action' do
      let(:action) { Action.first }
      before { subject }

      it 'is marked as a donation' do
        expect(action.donation?).to be true
      end

      describe 'form_data' do
        it 'has PYPL as card_num' do
          expect(action.form_data['card_num']).to eq('PYPL')
        end
      end
    end
  end
end
