module PaymentProcessor
  module GoCardless
    class Populator

      def transaction_params
        {
          amount: amount,
          currency: currency,
          links: {
              mandate: mandate.id
          }
        }
      end

      def subscription_params
        transaction_params.merge(
          {
            name: "donation",
            interval_unit: "monthly",
            day_of_month:  "1",
            metadata: {
              order_no: SecureRandom.uuid
            }
          })
      end

      def mandate
        @mandate ||= client.mandates.get(completed_redirect_flow.links.mandate)
      end

      def amount
        # we let the donor pick any amount and currency, then convert it to the right currency
        # for their bank according to the current exchange rate
        @amount ||= PaymentProcessor::Currency.convert(@original_amount, currency, @original_currency).cents
      end

      def currency
        scheme = mandate.scheme.downcase
        return 'GBP' if scheme == 'bacs'
        return 'SEK' if scheme == 'autogiro'
        return 'EUR'
      end

      def completed_redirect_flow
        client.redirect_flows.complete(@redirect_flow_id, params: { session_token: @session_token })
      rescue GoCardlessPro::InvalidStateError => e
        raise e unless e.message =~ /already completed/
        client.redirect_flows.get(@redirect_flow_id)
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

