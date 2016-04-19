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
        builder = new(params, session_id)
        builder.subscription
        builder
      end

      def initialize(params, session_id)
        @page_id = params[:page_id]
        @original_amount_in_cents = (params[:amount].to_f * 100).to_i # Price in pence/cents
        @original_currency = params[:currency].upcase
        @redirect_flow_id = params[:redirect_flow_id]
        @user = params[:user]
        @session_token = session_id
        @member = create_or_update_member(params)
      end

      def subscription
        subscription = client.subscriptions.create(params: subscription_params)

        @local_customer = Payment::GoCardless.write_customer(customer_id, @member_id)
        @local_mandate = Payment::GoCardless.write_mandate(mandate.id, mandate.scheme, mandate.next_possible_charge_date, @local_customer.id)
        @local_subscription = Payment::GoCardless.write_subscription(subscription.id, amount_in_whole_currency, currency, @page_id)
        @action = ManageDonation.create(params: action_params)
      rescue GoCardlessPro::Error => e
        @errors = e.errors
      end

      private

      def action_params
        @user.merge!(
          page_id:              @page_id,
          amount:               amount_in_whole_currency.to_s,
          card_num:             mandate.id,
          currency:             currency,
          subscription_id:      @local_subscription.go_cardless_id,
          is_subscription:      true,
          recurrence_number:    0,
          card_expiration_date: nil
        )
      end

    end
  end
end

