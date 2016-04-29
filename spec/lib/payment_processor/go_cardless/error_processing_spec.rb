require 'rails_helper'

module PaymentProcessor
  module GoCardless
    describe ErrorProcessing do

      let(:client) do
        GoCardlessPro::Client.new(
          access_token: Settings.gocardless.token,
          environment:  Settings.gocardless.environment.to_sym
        ) 
      end

      before :each do
        allow(Rails.logger).to receive(:error)
      end

      subject{ described_class.new(@error).process }

      describe 'with a GoCardless internal error', :pending do

        before :each do
          begin
            client.redirect_flows.create(params: {})
          rescue GoCardlessPro::GoCardlessError => e
            @error = e
          end
        end

        it 'logs the error to the Rails logger' do
          expect(Rails.logger).to receive(:error).with('')
          subject
        end

        it 'passes back the correct error' do
          expect(subject).to equal([{code: 500, message: I18n.t('fundraiser.unknown_error')}])
        end
      end

      describe 'with an API usage error'
      describe 'with a state error'
      describe 'with a validation error'
      describe 'with a generic error'

    end
  end
end
