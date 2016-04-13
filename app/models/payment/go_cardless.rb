module Payment::GoCardless
  class << self
    def table_name_prefix
      'payment_go_cardless_'
    end

    def write_transaction(response, page_id, member_id, existing_customer, save_customer=true)
      GoCardlessTransactionBuilder.build(response, page_id, member_id, existing_customer, save_customer)
    end

    def write_subscription(response, page_id, action_id, currency)
      # TODO: implement
      # if response is successful...
      Payment::GoCardless::Subscription.create!({})
    end

    def write_customer(response, member_id, existing_customer)
      GoCardlessCustomerBuilder.build(response, member_id, existing_customer)
    end

    def customer(email)
      customer = Payment::GoCardless::Customer.find_by(email: email)
      return customer if customer.present?
      member = Member.find_by(email: email)
      member.try(:go_cardless_customer)
    end

    class GoCardlessCustomerBuilder
      #
      # Stores and associates a GoCardless customer as +Payment::GoCardless::Customer+.
      #
      # === Options
      #
      # * +:gc_customer+ - A GoCardless::Customer response object for getting a single customer by ID.
      #                    (see https://developer.gocardless.com/pro/2015-07-06/#customers-get-a-single-customer)
      # * +:member_id+   - the member_id to associate with the customer record
      # * +:existing_customer+ - if passed, this customer is updated instead of creating a new one
      #
      def self.build(gc_customer, member_id, existing_customer)
        new(gc_customer, member_id, existing_customer).build
      end

      def initialize(gc_customer, member_id, existing_customer)
        @gc_customer = gc_customer
        @member_id = member_id
        @existing_customer = existing_customer
      end

      def build
        if @existing_customer.present?
          @existing_customer.update(customer_attrs)
        else
          Payment::GoCardless::Customer.create!(customer_attrs)
        end
      end

      def customer_attrs
        {
          member_id: @member_id,
          go_cardless_id: @gc_customer.id,
          email: @gc_customer.email,
          given_name: @gc_customer.given_name,
          family_name: @gc_customer.family_name,
          postal_code: @gc_customer.postal_code,
          country_code: @gc_customer.country_code,
          language: @gc_customer.language
        }
      end
    end

    class GoCardlessTransactionBuilder
      #
      # Stores and associates a GoCardless payment as +Payment::GoCardless::Transaction+.
      #
      # === Options
      #
      # * +:gc_payment+   - A GoCardless::Payment response object
      #                    (see https://developers.braintreepayments.com/reference/response/transaction/ruby)
      # * +:page_id+     - the id of the Page to associate with the transaction record
      # * +:member_id+   - the member_id to associate with the customer record
      # * +:existing_customer+ - if passed, this customer is updated instead of creating a new one
      # * +:save_customer+     - optional, default true. whether to save the customer info too
      #

      def self.build(gc_payment, page_id, member_id, existing_customer, save_customer)
        new(gc_payment, page_id, member_id, existing_customer, save_customer).build
      end

      def initialize(gc_payment, page_id, member_id, existing_customer, save_customer)
        @gc_payment = gc_payment
        @page_id = page_id
        @member_id = member_id
        @existing_customer = existing_customer
        @save_customer = save_customer
      end

      def build
        @mandate = ::Payment::GoCardless::PaymentMethod.find_or_create_by!({
           go_cardless_id: @gc_payment.links.mandate,
           customer_id: @existing_customer.id
         })
        ::Payment::GoCardlessTransaction.create(transaction_attrs)
      end

     private

      def transaction_attrs
        {
          go_cardless_id: @gc_payment.id,
          charge_date: @gc_payment.charge_date,
          amount: @gc_payment.amount,
          description: @gc_payment.description,
          currency: @gc_payment.currency,
          reference: @gc_payment.reference,
          amount_refunded: @gc_payment.amount_refunded,
          page_id: @page_id,
          # Braintree transactions don't belong to actions, but subscriptions do. Which way do we want to keep this?
          # action_id: ,
          customer_id: @existing_customer.id,
          payment_method_id: @mandate.id,
          status: status
        }
      end

      def status
        Payment::GoCardless::Transaction.statuses[@gc_payment.status.to_sym]
      end
    end
  end
end
