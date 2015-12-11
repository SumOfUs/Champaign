require 'rails_helper'

module PaymentProcessor
  module Clients
    module Braintree
      describe MerchantAccountSelector do
        subject { described_class }

        describe '.for_currency' do
          context 'unmatched currency' do
            it 'raises' do
              expect{
                subject.for_currency('VVZ')
              }.to raise_error(Exceptions::InvalidCurrency, 'No merchant account is associated with this currency: VVZ')
            end
          end

          context 'matched currency' do

            it 'returns merchant account ID' do
              expect( subject.for_currency('EUR') ).to eq('EUR')
            end
          end
        end
      end
    end
  end
end
