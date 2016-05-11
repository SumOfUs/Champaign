module PaymentProcessor
  module GoCardless
    class Populator

      def request_params
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

      def transaction_params
        request_params.merge({
          charge_date: charge_date
        })
      end

      def subscription_params
        request_params.merge(
          {
            name: "donation",
            interval_unit: "monthly"
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

      def charge_date
        return mandate.next_possible_charge_date unless mandate.scheme.downcase == 'bacs'
        mandate_date = Date.parse(mandate.next_possible_charge_date)
        # GBP needs to be charged on 20th of the month. Use the next possible 20th day allowed by the mandate.
        if mandate_date.day <= 20
          # if mandate becomes available before the 20th of this month, charge the payment on the 20th of this month
          month = mandate_date.month
        else
          # if the mandate becomes available only after the 20th this month, charge on the 20th of next month
          month = mandate_date.month + 1
        end
        Date.new(mandate_date.year, month, Settings.gocardless.gbp_charge_day.to_i).to_s
      end

      def error_container
        @error
      end

      def success?
        @error.blank?
      end
    end
  end
end

