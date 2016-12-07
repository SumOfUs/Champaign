# frozen_string_literal: true

require 'rails_helper'

describe 'Pledger' do
  let!(:page) { create(:page, slug: 'hello-world', title: 'Hello World') }
  let!(:fundraiser) { create(:plugins_fundraiser, pledge: true, page: page) }
  let(:form) { create(:form) }
  let(:member) { create(:member, email: 'test@example.com') }
  let(:payment_nonce) { 'fake-valid-nonce' }

  let(:payment_params) do
    {
      currency: 'EUR',
      payment_method_nonce: payment_nonce,
      recurring: false,
      amount: 1.00,
      store_in_vault: false,
      user: {
        form_id: form.id,
        email: 'test@example.com',
        name: 'John Doe'
      }
    }
  end

  before do
    allow(ChampaignQueue).to receive(:push)
    allow(::Braintree::Transaction).to receive(:sale).and_call_original
  end

  describe 'member making an express donation pledge' do
    let(:customer)        { create(:payment_braintree_customer, member: member) }
    let(:payment_method) { create(:payment_braintree_payment_method, customer: customer, token: '6vg2vw') }

    before do
      body = {
        payment: {
          amount: 1.00,
          payment_method_id: payment_method.id,
          currency: 'EUR',
          recurring: false
        },
        user: payment_params[:user],
        page_id: page.id
      }

      VCR.use_cassette('braintree_express_pledge_donation') do
        post api_payment_braintree_one_click_path(page.id), body
      end
    end

    it 'marks local transaction as a pledge' do
      transaction = Payment::Braintree::Transaction.where(page_id: page.id).first
      expect(transaction.pledge).to be(true)
    end

    it 'does not settle transaction sale on braintree' do
      expected_args = {
        options: hash_including(submit_for_settlement: false)
      }

      expect(::Braintree::Transaction).to have_received(:sale)
        .with(hash_including(expected_args))
    end
  end

  describe 'member making a credit card pledge' do
    before do
      VCR.use_cassette('braintree_card_pledge_donation') do
        post api_payment_braintree_transaction_path(page.id), payment_params
      end
    end

    it 'does not settle transaction sale on braintree' do
      expected_args = {
        options: hash_including(submit_for_settlement: false)
      }

      expect(::Braintree::Transaction).to have_received(:sale)
        .with(hash_including(expected_args))
    end

    it 'marks local transaction as a pledge' do
      transaction = Payment::Braintree::Transaction.where(page_id: page.id).first
      expect(transaction.pledge).to be(true)
    end
  end

  describe 'member making a paypal pledge' do
    let(:payment_nonce) { 'fake-paypal-one-time-nonce' }

    before do
      VCR.use_cassette('braintree_paypal_pledge_donation') do
        post api_payment_braintree_transaction_path(page.id), payment_params
      end
    end

    it 'does not settle transaction sale on braintree' do
      expected_args = {
        options: hash_including(submit_for_settlement: false)
      }

      expect(::Braintree::Transaction).to have_received(:sale)
        .with(hash_including(expected_args))
    end

    it 'marks local transaction as a pledge' do
      transaction = Payment::Braintree::Transaction.where(page_id: page.id).first
      expect(transaction.pledge).to be(true)
    end
  end
end
