# frozen_string_literal: true
require 'rails_helper'

describe 'API::Stateless GoCardless Subscriptions' do
  include Requests::RequestHelpers
  include AuthToken

  let!(:member) { create(:member, email: 'test@example.com') }
  let!(:customer) do
    create(:payment_go_cardless_customer,
           member: member,
           go_cardless_id: '1337',
           email: 'test@example.com',
           country_code: 'US',
           language: 'en')
  end
  let!(:payment_method) do
    create(:payment_go_cardless_payment_method,
           id: 321,
           go_cardless_id: 1_234_566,
           customer: customer,
           scheme: 'sepa_core',
           created_at: Time.now)
  end
  let!(:subscription) do
    create(:payment_go_cardless_subscription,
           customer: customer,
           payment_method: payment_method,
           created_at: Time.now)
  end
  let!(:subscription_transaction) do
    create(:payment_go_cardless_transaction,
           subscription: subscription,
           customer: customer,
           go_cardless_id: 999,
           amount: 4,
           currency: 'GBP',
           charge_date: Date.tomorrow,
           payment_method: payment_method)
  end
  let!(:one_off_transaction) do
    create(:payment_go_cardless_transaction,
           go_cardless_id: 1_234_546,
           customer: customer,
           payment_method: payment_method,
           amount: 15.5,
           currency: 'EUR',
           charge_date: Date.today)
  end

  before :each do
    member.create_authentication(password: 'password')
  end

  def auth_headers
    token = encode_jwt(member.token_payload)
    { authorization: "Bearer #{token}" }
  end

  def first_transaction
    json_hash.first.deep_symbolize_keys!
  end

  describe 'GET index' do
    it 'returns a list of one-off transactions with their payment methods' do
      get '/api/stateless/go_cardless/transactions', nil, auth_headers
      expect(response.status).to eq(200)
      expect(json_hash).to be_an Array
      expect(first_transaction).to include(id: one_off_transaction.id,
                                           go_cardless_id: '1234546',
                                           charge_date: /^\d{4}-\d{2}-\d{2}/,
                                           amount: '15.5',
                                           description: nil,
                                           currency: 'EUR',
                                           aasm_state: 'created',
                                           payment_method: {
                                             id: 321,
                                             go_cardless_id: '1234566',
                                             scheme: 'sepa_core',
                                             next_possible_charge_date: nil,
                                             created_at: /^\d{4}-\d{2}-\d{2}/
                                           })
    end

    it 'does not list transactions that are associated with subscriptions' do
      get '/api/stateless/go_cardless/transactions', nil, auth_headers
      expect(response.status).to eq(200)
      expect(first_transaction.keys).to match([
        :id,
        :go_cardless_id,
        :charge_date,
        :amount,
        :description,
        :currency,
        :aasm_state,
        :payment_method
      ])
      expect(first_transaction).to_not include(id: subscription_transaction.id,
                                               go_cardless_id: subscription_transaction.go_cardless_id,
                                               amount: subscription_transaction.amount,
                                               currency: subscription_transaction.currency)
    end
  end
end
