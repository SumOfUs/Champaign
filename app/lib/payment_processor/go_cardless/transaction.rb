# frozen_string_literal: true

module PaymentProcessor
  module GoCardless
    class Transaction < Populator
      # = GoCardless::Transaction
      #
      # Wrapper around GoCardless's Ruby SDK. This class essentially just stuffs parameters
      # into the keys that are expected by GoCardless's class. Most of the good stuff happens
      # in the Populator class, which is inherited by this and Transaction.
      #
      # == Usage
      #
      # Call <tt>PaymentProcessor::Clients::GoCardless::Transaction.make_transaction</tt>
      #
      # === Options #
      # * +:amount+   - Billing amount (required)
      # * +:currency+ - Billing currency (required)
      # * +:user+     - Hash of information describing the customer. Must include email, and name (required)
      # * +:page_id+  - The ID of the page to associate the transaction with (required)
      # * +:redirect_flow_id+  - The GoCardless ID of the redirect flow to complete (required)
      # * +:session_token+     - The session id for the redirect flow (required)
      #

      attr_reader :error, :action

      def self.make_transaction(params)
        builder = new(params)
        builder.transact
        builder
      end

      def initialize(amount:, currency:, user:, page_id:, redirect_flow_id:, session_token:)
        @page_id = page_id
        @original_amount_in_cents = (amount.to_f * 100).to_i # Price in pence/cents
        @original_currency = currency.try(:upcase)
        @redirect_flow_id = redirect_flow_id
        @user = user
        @session_token = session_token
      end

      def transact
        @transaction = client.payments.create(params: transaction_params)
        @action = ManageDonation.create(params: action_params)
        @local_customer = Payment::GoCardless.write_customer(customer_id, @action.member_id)
        @local_mandate = Payment::GoCardless.write_mandate(mandate.id, mandate.scheme, mandate.next_possible_charge_date, @local_customer.id)

        @local_transaction = Payment::GoCardless.write_transaction(
          uuid: @transaction.id,
          amount: amount_in_whole_currency,
          currency: currency,
          charge_date: @transaction.charge_date,
          page_id: @page_id,
          customer_id: @local_customer.id,
          payment_method_id: @local_mandate.id
        )
      rescue GoCardlessPro::Error => e
        @error = e
      end

      def transaction_id
        @transaction.try(:id)
      end

      private

      def action_params
        @user.merge!(
          page_id:          @page_id,
          amount:           amount_in_whole_currency.to_s,
          card_num:         mandate.id,
          currency:         currency,
          transaction_id:   transaction_id,
          is_subscription:  false,
          payment_provider: 'go_cardless',
          mandate_reference: mandate.reference,
          bank_name:        bank_account.bank_name,
          account_number_ending: bank_account.account_number_ending
        )
      end
    end
  end
end
