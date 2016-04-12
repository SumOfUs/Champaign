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
      # === Options #
      # * +:amount+   - Billing amount (required)
      # * +:currency+ - Billing currency (required)
      # * +:user+     - Hash of information describing the customer. Must include email, and name (required)
      # * +:customer+ - Instance of existing GoCardless customer. Must respond to +customer_id+ (optional)
      attr_reader :result, :action

      def self.make_transaction(params, session_id)
        new(params, session_id).transaction
      end

      def self.make_subscription(params, session_id)
        new(params, session_id).subscription
      end

      def initialize(params, session_id)
        @amount = params[:amount].to_i * 100 # Price in pence/cents
        @redirect_flow_id = params[:redirect_flow_id]
        @session_token = session_id
      end

      def transaction
        transaction = client.payments.create(params: transaction_params)
        # TODO: persist transaction locally
      end

      def subscription
        # We're going to need to write some logic reconciling currency, quantity, and DD scheme
        subscription = client.subscriptions.create(params: subscription_params)
        # TODO: persist subscription locally
      end

      private

      def transaction_params
        {
          amount: @amount,
          currency: currency,
          links: {
              mandate: mandate.id
          }
        }
      end

      def subscription_params
        transaction_params.merge{
          name: "donation",
          interval_unit: "monthly",
          day_of_month:  "1",
          metadata: {
            order_no: SecureRandom.uuid
          }
        }
      end

      def mandate
        client.mandates.get(completed_redirect_flow.links.mandate)
      end

      def currency
        case mandate.scheme
          when "bacs" then "GBP"
          when "sepa_core" then "EUR"
        end
      end

      def completed_redirect_flow
        client.redirect_flows.get(@redirect_flow_id) || client.redirect_flows.complete(@redirect_flow_id, params: { session_token: @session_token })
      end

      def client
        GoCardlessPro::Client.new(
          access_token: Settings.gocardless.token,
          environment: Settings.gocardless.environment.to_sym
        )
      end
    end
  end
end

