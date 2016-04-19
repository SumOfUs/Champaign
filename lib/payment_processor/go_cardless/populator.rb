module PaymentProcessor
  module GoCardless
    class Populator

      def transaction_params
        {
          amount: amount_in_cents,
          currency: currency,
          links: {
            mandate: mandate.id
          },
          metadata: {
            customer_id: customer_id
          }
        }
      end

      def subscription_params
        transaction_params.merge(
          {
            name: "donation",
            interval_unit: "monthly",
            day_of_month:  "1",
          }
        )
      end

      def mandate
        @mandate ||= client.mandates.get(complete_redirect_flow.links.mandate)
      end

      def customer_id
        complete_redirect_flow.links.customer
      end

      def amount_in_cents
        # we let the donor pick any amount and currency, then convert it to the right currency
        # for their bank according to the current exchange rate
        @amount ||= PaymentProcessor::Currency.convert(@original_amount_in_cents, currency, @original_currency).cents
      end

      def amount_in_whole_currency
        amount_in_cents.to_f / 100
      end

      def currency
        scheme = mandate.scheme.downcase
        return 'GBP' if scheme == 'bacs'
        return 'SEK' if scheme == 'autogiro'
        return 'EUR'
      end

      def complete_redirect_flow
        @complete_redirect_flow ||= client.redirect_flows.complete(@redirect_flow_id, params: { session_token: @session_token })
      rescue GoCardlessPro::InvalidStateError => e
        raise e unless e.message =~ /already completed/
        @complete_redirect_flow = client.redirect_flows.get(@redirect_flow_id)
      end

      def client
        GoCardlessPro::Client.new(
          access_token: Settings.gocardless.token,
          environment: Settings.gocardless.environment.to_sym
        )
      end

      def success?
        @errors.blank?
      end
    end
  end
end

