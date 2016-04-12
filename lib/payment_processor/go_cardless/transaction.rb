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
        @page_id = params[:page_id]
        @amount = (params[:amount].to_f * 100).to_i # Price in pence/cents
        @member = Member.find_or_create_by(email: params[:user][:email])
        @redirect_flow_id = params[:redirect_flow_id]
        @session_token = session_id
      end

      def transaction
        transaction = client.payments.create(params: transaction_params)
        # TODO: persist transaction locally
        action = build_action
        Payment::GoCardless.write_transaction(transaction, @page_id, @member, existing_customer, true)
      end

    end
  end
end

