module PaymentProcessor
  module GoCardless
    class Subscription < Populator
      # = GoCardless::Subscription
      #
      # Wrapper around GoCardless's Ruby SDK. This class essentially just stuffs parameters
      # into the keys that are expected by GoCardless's class.
      #
      # == Usage
      #
      # Call <tt>PaymentProcessor::Clients::GoCardless::Subscription.make_subscription</tt>
      #
      attr_reader :result, :action

      def self.make_subscription(params, session_id)
        new(params, session_id).subscription
      end

      def initialize(params, session_id)
        @original_amount = (params[:amount].to_f * 100).to_i # Price in pence/cents
        @original_currency = params[:currency].upcase
        @redirect_flow_id = params[:redirect_flow_id]
        @session_token = session_id
      end

      def subscription
        # We're going to need to write some logic reconciling currency, quantity, and DD scheme
        subscription = client.subscriptions.create(params: subscription_params)
        # TODO: persist subscription locally
      end

    end
  end
end

