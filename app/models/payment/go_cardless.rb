module Payment::GoCardless
  class << self
    def table_name_prefix
      'payment_go_cardless_'
    end

    def write_transaction(gc_mandate, gc_payment, page_id, member, save_customer=true)
      GoCardlessTransactionBuilder.build(gc_mandate, gc_payment, page_id, member, save_customer)
    end

    def write_subscription(gc_mandate, gc_subscription, page_id, member, save_customer=true)
      # TODO: implement
      # if response is successful...
      Payment::GoCardless::Subscription.create!(subscription_attrs)
    end

    def write_customer(gc_customer, member)
      GoCardlessCustomerBuilder.build(gc_customer, member)
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
      #
      def self.build(gc_customer, member)
        new(gc_customer, member).build
      end

      def initialize(gc_customer, member)
        @gc_customer = gc_customer
        @member = member
        @customer = member.go_cardless_customer
      end

      def build
        if @customer.present?
          @customer.update(customer_attrs)
        else
          Payment::GoCardless::Customer.create!(customer_attrs)
        end
      end

      def customer_attrs
        {
          member_id: @member.id,
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

      def self.build(gc_mandate, gc_payment, page_id, member, save_customer)
        new(gc_mandate, gc_payment, page_id, member, save_customer).build
      end

      def initialize(gc_mandate, gc_payment, page_id, member, save_customer)
        @gc_mandate = gc_mandate
        @gc_payment = gc_payment
        @page_id = page_id
        @member = member
        @customer = member.go_cardless_customer
        @save_customer = save_customer
      end

      def build
        if @customer.present?
          @customer.update_attributes(customer_attrs)
        else
          @customer = ::Payment::GoCardless::Customer.create(customer_attrs)
        end
        @mandate = ::Payment::GoCardless::PaymentMethod.find_or_initialize_by({
           go_cardless_id: @gc_payment.links.mandate,
           customer_id: @customer.id,
         })
        @mandate.status = @gc_mandate.status.to_sym
        @mandate.save
        ::Payment::GoCardless::Transaction.create(transaction_attrs)
      end

     private

      def customer_attrs
        {
          member_id: @member.id,
          go_cardless_id: @gc_payment.metadata["customer_id"]
        }
      end

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
          customer_id: @customer.id,
          payment_method_id: @mandate.id,
          status: status
        }
      end

      def subscription_attrs
        {

        }
      end

      def status
        Payment::GoCardless::Transaction.statuses[@gc_payment.status.to_sym]
      end
    end
  end
end
