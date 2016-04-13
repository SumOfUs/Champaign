module PaymentProcessor
  module GoCardless
    class Transaction < Populator
      include ActionBuilder
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
      # * +:customer+ - Instance of existing GoCardless customer. Must respond to +customer_id+ (optional)
      attr_reader :result, :action

      def self.make_transaction(params, session_id)
        new(params, session_id).transaction
      end

      def initialize(params, session_id)
        @params = params
        @original_amount = (params[:amount].to_f * 100).to_i # Price in pence/cents
        @original_currency = params[:currency].upcase
        @redirect_flow_id = params[:redirect_flow_id]
        @session_token = session_id
      end

      def transaction
        transaction = client.payments.create(params: transaction_params)
        build_action # This builds the action and generates the instance variables @page and @existing_member
        Payment::GoCardless.write_transaction(transaction, @page.id, @existing_member.id, @existing_member.go_cardless_customer, true)
      end

      # This has been overridden for ActionBuilder used on line 37 to create an action and a member associated with it,
      # if the member hasn't taken action before.
      def existing_member
        @existing_member ||= Member.find_or_initialize_by( email: @params[:user][:email] )
      end

    end
  end
end

