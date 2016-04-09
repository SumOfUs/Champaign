module PaymentProcessor
  module GoCardless
    class Transaction
      # = GoCardless::Transaction
      #
      # Wrapper around GoCardless's Ruby SDK. This class essentially just stuffs parameters
      # into the keys that are expected by GoCardless's class.
      #
      # == Usage
      #
      # Call <tt>PaymentProcessor::Clients::GoCardless::Transaction.make_transaction</tt>
      #
      # === Options
      #
      # * +:nonce+    - GoCardless token that references a payment method provided by the client (required)
      # * +:amount+   - Billing amount (required)
      # * +:currency+ - Billing currency (required)
      # * +:user+     - Hash of information describing the customer. Must include email, and name (required)
      # * +:customer+ - Instance of existing GoCardless customer. Must respond to +customer_id+ (optional)
      attr_reader :result, :action

      def self.make_transaction(params, session_id)
        builder = new(params, session_id)
        builder.transaction
        builder
      end

      def initialize(params, session_id)
        @redirect_flow_id = params[:redirect_flow_id]
        @session_token = session_id
      end

      def transaction
        completed_redirect_flow = client.redirect_flows.complete(@redirect_flow_id, params: { session_token: @session_token })

        mandate = client.mandates.get(completed_redirect_flow.links.mandate)

        # We're going to need to write some logic reconciling currency, quantity, and DD scheme
        currency = case mandate.scheme
                 when "bacs" then "GBP"
                 when "sepa_core" then "EUR"
                 end


        subscription = client.subscriptions.create(params: {
          amount: params[:amount] * 100, # Price in pence/cents
          currency: currency,
          name: "donation",
          interval_unit: "monthly",
          day_of_month:  "1",
          metadata: {
            order_no: SecureRandom.uuid
          },
          links: {
            mandate: mandate.id
          }
        })
      end

      private

      def client
        GoCardlessPro::Client.new(
          access_token: Settings.gocardless.token,
          environment: Settings.gocardless.environment.to_sym
        )
      end
    end
  end
end

