# frozen_string_literal: true

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
      let(:request_id) { 'dd50eaaf-8213' }
      let(:backtrace) do
        ["  undefined method `type' for nil:NilClass",
         "# ./lib/payment_processor/go_cardless/error_processing.rb:11:in `process'",
         "# ./spec/lib/payment_processor/go_cardless/error_processing_spec.rb:18:in `block (2 levels) in <module:GoCardless>'"]
      end
      let(:generic_error) do
        instance_double(
          GoCardlessPro::Error,
          class: GoCardlessPro::Error,
          type: '',
          message: 'Unknown error',
          code: 500,
          request_id: request_id,
          backtrace: backtrace
        )
      end
      let(:api_error) do
        instance_double(
          GoCardlessPro::InvalidApiUsageError,
          class: GoCardlessPro::InvalidApiUsageError,
          type: 'invalid_api_usage',
          message: 'Invalid document structure',
          code: 400,
          backtrace: backtrace,
          request_id: request_id,
          errors: [{
            "reason": 'invalid_document_structure',
            "message": 'Invalid document structure'
          }]
        )
      end
      let(:go_cardless_error) do
        instance_double(
          GoCardlessPro::GoCardlessError,
          class: GoCardlessPro::GoCardlessError,
          type: 'gocardless',
          message: '500 - internal server error',
          code: 500,
          request_id: request_id
        )
      end

      before :each do
        allow(Rails.logger).to receive(:error)
      end

      subject { described_class.new(error).process }

      describe 'with a GoCardless internal error' do
        let(:error) { go_cardless_error }

        it 'logs the error to the Rails logger' do
          expect(Rails.logger).to receive(:error).with("GoCardlessPro::GoCardlessError: 500 - internal server error. Please report to GoCardless support staff. (request: #{request_id})")
          subject
        end

        it 'passes back the correct error' do
          expect(subject).to eq [{ code: 500, message: I18n.t('fundraiser.unknown_error') }]
        end
      end

      describe 'with an API usage error' do
        let(:error) { api_error }

        it 'logs the error to the Rails logger' do
          expect(Rails.logger).to receive(:error).with("GoCardlessPro::InvalidApiUsageError:   undefined method `type' for nil:NilClass\n# ./lib/payment_processor/go_cardless/error_processing.rb:11:in `process'\n# ./spec/lib/payment_processor/go_cardless/error_processing_spec.rb:18:in `block (2 levels) in <module:GoCardless>' (request: dd50eaaf-8213)")
          subject
        end

        it 'passes back the correct error' do
          expect(subject).to eq [{ code: 400, message: 'Our technical team has been notified. Please double check your info or try a different payment method.' }]
        end
      end

      describe 'with a state error' do
        let(:error) do
          instance_double(
            GoCardlessPro::InvalidStateError,
            class: GoCardlessPro::InvalidStateError,
            type: 'invalid_state',
            message: 'This payment has already been canceled',
            code: 409,
            errors: [{
              'reason' => 'cancellation_failed',
              'message' => 'This payment has already been canceled'
            }],
            request_id: request_id
          )
        end

        it 'logs the error to the Rails logger' do
          expect(Rails.logger).to receive(:error).with("GoCardlessPro::InvalidStateError: This payment has already been canceled. This payment has already been canceled (request: #{request_id})")
          subject
        end

        it 'passes back the correct error' do
          expect(subject).to eq [{ code: 409, message: 'This payment has already been canceled' }]
        end
      end

      describe 'with a validation error' do
        let(:error) do
          instance_double(
            GoCardlessPro::Error,
            class: GoCardlessPro::Error,
            type: 'validation_failed',
            message: 'Validation failed',
            code: 422,
            errors: [
              {
                'field' => 'branch_code',
                'message' => 'must be a number',
                'request_pointer' => '/customer_bank_accounts/branch_code'
              }, {
                'field' => 'branch_code',
                'message' => 'is the wrong length (should be 8 characters)',
                'request_pointer' => '/customer_bank_accounts/branch_code'
              }
            ],
            request_id: request_id
          )
        end

        it 'logs the error to the Rails logger' do
          expect(Rails.logger).to receive(:error).with("GoCardlessPro::Error: branch_code must be a number. branch_code is the wrong length (should be 8 characters) (request: #{request_id})")
          subject
        end

        it 'passes back the correct error' do
          expect(subject).to eq [{ code: 422, attribute: 'branch_code', message: 'branch_code must be a number' }, { code: 422, attribute: 'branch_code', message: 'branch_code is the wrong length (should be 8 characters)' }]
        end
      end

      describe 'with a generic error' do
        let(:error) { generic_error }

        it 'logs the error to the Rails logger' do
          expect(Rails.logger).to receive(:error).with("GoCardlessPro::Error:   undefined method `type' for nil:NilClass\n# ./lib/payment_processor/go_cardless/error_processing.rb:11:in `process'\n# ./spec/lib/payment_processor/go_cardless/error_processing_spec.rb:18:in `block (2 levels) in <module:GoCardless>' (request: #{request_id})")
          subject
        end

        it 'passes back the correct error' do
          expect(subject).to eq [{ code: 500, message: 'Our technical team has been notified. Please double check your info or try a different payment method.' }]
        end
      end

      %i[fr de].each do |locale|
        describe "with language as #{locale}" do
          let(:messages) do
            {
              fr: 'Notre équipe technique a été notifiée de ce problème. Veuillez revérifier vos informations ou choisir une autre méthode de paiement.',
              de: 'Unbekannter Fehler. Unser Team wurde benachrichtigt. Bitte überprüfen Sie Ihre Eingaben oder wählen Sie eine andere Zahlungsmethode.'
            }
          end
          subject { described_class.new(@error, locale: locale).process }

          it 'returns the correct message for a generic error' do
            @error = generic_error
            expect(subject).to eq [{ code: 500, message: messages[locale] }]
          end

          it 'returns the correct message for a GoCardless internal error' do
            @error = go_cardless_error
            expect(subject).to eq [{ code: 500, message: messages[locale] }]
          end

          it 'returns the correct message for an API usage error' do
            @error = api_error
            expect(subject).to eq [{ code: 400, message: messages[locale] }]
          end
        end
      end
    end
  end
end
