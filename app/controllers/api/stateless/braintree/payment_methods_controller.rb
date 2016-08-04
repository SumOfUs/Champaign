# frozen_string_literal: true
module Api
  module Stateless
    module Braintree
      class PaymentMethodsController < StatelessController
        before_filter :authenticate_request!

        def index
          methods = @current_member.braintree_customer.payment_methods
          #methods = ::Payment::Braintree::PaymentMethod.joins(:customer).where('payment_braintree_customers': { email: @current_member.email })
          #byebug
          render json: methods
        end

      end
    end
  end
end


#SELECT "payment_braintree_payment_methods".* FROM "payment_braintree_payment_methods" 
#INNER JOIN "payment_braintree_customers" ON 
#"payment_braintree_customers"."id" = "payment_braintree_payment_methods"."customer_id"
#WHERE "customer"."email" = $1
