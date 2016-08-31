# frozen_string_literal: true
require 'rails_helper'

describe 'API::Stateless GoCardless PaymentMethods' do
  include Requests::RequestHelpers
  include AuthToken
  let!(:member) { create(:member, email: 'test@example.com') }
  let!(:customer) { create(:payment_go_cardless_customer, member: member) }
  let!(:payment_method) do
    create(:payment_go_cardless_payment_method,
           customer: customer,
           id: 1432,
           go_cardless_id: 9898,
           scheme: 'bacs',
           next_possible_charge_date: Date.tomorrow,
           created_at: Time.now)
  end

  before :each do
    member.create_authentication(password: 'password')
  end

  def auth_headers
    token = encode_jwt(member.token_payload)
    { authorization: "Bearer #{token}" }
  end

  describe 'GET index' do
    it 'returns payment methods for member' do
      get '/api/stateless/go_cardless/payment_methods', nil, auth_headers
      expect(response.status).to eq(200)
      expect(json_hash.first.deep_symbolize_keys!).to include(id: 1432,
                                                              go_cardless_id: '9898',
                                                              scheme: 'bacs',
                                                              next_possible_charge_date: /^\d{4}-\d{2}-\d{2}/,
                                                              created_at: /^\d{4}-\d{2}-\d{2}/)
    end
  end
end
