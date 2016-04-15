module PaymentProcessor
  module GoCardless
    class Populator

      def transaction_params
        {
          amount: amount,
          currency: currency,
          links: {
              mandate: mandate.id
          },
          metadata: {
              customer_id: complete_redirect_flow.links.customer
          }
        }
      end

      def subscription_params
        transaction_params.merge(
          {
            name: "donation",
            interval_unit: "monthly",
            day_of_month:  "1",
          })
      end

      def mandate
        @mandate ||= client.mandates.get(complete_redirect_flow.links.mandate)
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

      def complete_redirect_flow
        @complete_redirect_flow ||= client.redirect_flows.complete(@redirect_flow_id, params: { session_token: @session_token })
      rescue GoCardlessPro::InvalidStateError => e
        @errors = e.errors unless e.message =~ /already completed/
        @complete_redirect_flow = client.redirect_flows.get(@redirect_flow_id)
      end

      def client
        GoCardlessPro::Client.new(
          access_token: Settings.gocardless.token,
          environment: Settings.gocardless.environment.to_sym
        )
      end

      def self.success?
        @errors.blank?
      end

      def create_or_update_member(params)
        splitter = NameSplitter.new(full_name: params[:user][:name])
        member_params = params[:user].except(:form_id, :name).merge({
                                                                         first_name: splitter.first_name,
                                                                         last_name: splitter.last_name
                                                                     })
        member = Member.find_or_create_by(email: member_params[:email])
        member.update_attributes(member_params.permit(:first_name, :last_name, :country, :postal, :email))
        member
      end
    end
  end
end

