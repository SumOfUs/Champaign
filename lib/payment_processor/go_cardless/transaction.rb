module PaymentProcessor
  module GoCardless
    class Transaction < Populator
      # = GoCardless::Transaction
      #
      # Wrapper around GoCardless's Ruby SDK. This class essentially just stuffs parameters
      # into the keys that are expected by GoCardless's class.
      #
      # == Usage
      #
      # Call <tt>PaymentProcessor::Clients::GoCardless::Transaction.make_transaction</tt>
      #
      # === Options #
      # * +:amount+   - Billing amount (required)
      # * +:currency+ - Billing currency (required)
      # * +:user+     - Hash of information describing the customer. Must include email, and name (required)
      # * +:customer+ - Instance of existing GoCardless customer. Must respond to +go_cardless_id+ (optional)
      # 
        # def payment_options
        #   {
        #     nonce: params[:payment_method_nonce],
        #     amount: params[:amount].to_f,
        #     user: params[:user],
        #     currency: params[:currency],
        #     page_id: params[:page_id]
        #   }
        # end

      attr_reader :errors, :action

      def self.make_transaction(params)
        builder = new(params)
        builder.transaction
        builder
      end

      def initialize(amount:, currency:, user:, page_id:, redirect_flow_id:, session_token:)
        @page_id = page_id
        @original_amount_in_cents = (amount.to_f * 100).to_i # Price in pence/cents
        @original_currency = currency.upcase
        @redirect_flow_id = redirect_flow_id
        @user = user
        @session_token = session_token
      end

      def transaction
        transaction = client.payments.create(params: transaction_params)

        @local_transaction = Payment::GoCardless.write_transaction(transaction.id, amount_in_whole_currency, currency, @page_id)
        @action = ManageDonation.create(params: action_params)
        @local_customer = Payment::GoCardless.write_customer(customer_id, @action.member_id)
        @local_mandate = Payment::GoCardless.write_mandate(mandate.id, mandate.scheme, mandate.next_possible_charge_date, @local_customer.id)
      rescue GoCardlessPro::Error => e
        @errors = e.errors
      end

      def transaction_id
        @local_transaction.try(:go_cardless_id)
      end

      private

      def action_params
        @user.merge!(
          page_id:              @page_id,
          amount:               amount_in_whole_currency.to_s,
          card_num:             mandate.id,
          currency:             currency,
          transaction_id:       @local_transaction.go_cardless_id,
          is_subscription:      false,
          card_expiration_date: nil
        )
      end

    end
  end
end

