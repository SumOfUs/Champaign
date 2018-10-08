# frozen_string_literal: true

module PaymentProcessor
  module GoCardless
    class Populator
      def self.client
        GoCardlessPro::Client.new(
          access_token: Settings.gocardless.token,
          environment: Settings.gocardless.environment.to_sym
        )
      end

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
        request_params.merge(charge_date: charge_date)
      end

      def subscription_params
        request_params.merge(
          name: 'donation',
          interval_unit: 'monthly',
          start_date: charge_date
        )
      end

      def mandate
        @mandate ||= client.mandates.get(complete_redirect_flow.links.mandate)
      end

      def bank_account
        @bank_account ||= client.customer_bank_accounts.get(complete_redirect_flow.links.customer_bank_account)
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
        case mandate.scheme.downcase
        when 'becs'
          'AUD'
        when 'bacs'
          'GBP'
        when 'autogiro'
          'SEK'
        else
          'EUR'
        end
      end

      def bacs?
        mandate.scheme.downcase.inquiry.bacs?
      end

      def complete_redirect_flow
        @complete_redirect_flow ||= client
          .redirect_flows
          .complete(@redirect_flow_id, params: { session_token: @session_token })
      rescue GoCardlessPro::InvalidStateError => e
        raise e unless e.message.match?(/already completed/)
        @complete_redirect_flow = client.redirect_flows.get(@redirect_flow_id)
      end

      def client
        self.class.client
      end

      def charge_date
        if Settings.gocardless.gbp_charge_day.blank? || !bacs?
          return mandate.next_possible_charge_date
        end

        mandate_date = Date.parse(mandate.next_possible_charge_date)
        gbp_date = create_gbp_date(mandate_date)

        if mandate_date <= gbp_date
          # if mandate becomes available before the specified date this month, charge the payment on the desired date.
          gbp_date.to_s
        else
          # if the mandate becomes available only after the date this month, charge on the desired date next month.
          gbp_date.next_month.to_s
        end
      end

      def settings_charge_day
        @settings_charge_day ||= Settings.gocardless.gbp_charge_day.to_i
      end

      def create_gbp_date(mandate_date)
        # GBP needs to be charged on the specified date. Use the next possible time that date is possible.
        Date.new(
          mandate_date.year,
          mandate_date.month,
          Settings.gocardless.gbp_charge_day.to_i
        )
      rescue ArgumentError
        Rails.logger.error(
          "With #{mandate_date.year}-#{mandate_date.month}-#{Settings.gocardless.gbp_charge_day.to_i}, \
your GBP charge date is invalid! Resorting to the mandate's next possible charge date."
        )
        mandate_date
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
