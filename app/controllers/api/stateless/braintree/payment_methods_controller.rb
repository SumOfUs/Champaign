# frozen_string_literal: true
<<<<<<< HEAD

=======
>>>>>>> 4f53a2d... Partial attempt at refactoring payment method creation
module Api
  module Stateless
    module Braintree
      class PaymentMethodsController < StatelessController
        before_filter :authenticate_request!

        def index
<<<<<<< HEAD
          @payment_methods = @current_member.braintree_customer.payment_methods
=======
          methods = @current_member.braintree_customer.payment_methods
          #methods = ::Payment::Braintree::PaymentMethod.joins(:customer).where('payment_braintree_customers': { email: @current_member.email })
          #byebug
          render json: methods
>>>>>>> 4f53a2d... Partial attempt at refactoring payment method creation
        end

      end
    end
  end
end
<<<<<<< HEAD
=======


#SELECT "payment_braintree_payment_methods".* FROM "payment_braintree_payment_methods" 
#INNER JOIN "payment_braintree_customers" ON 
#"payment_braintree_customers"."id" = "payment_braintree_payment_methods"."customer_id"
#WHERE "customer"."email" = $1
>>>>>>> 4f53a2d... Partial attempt at refactoring payment method creation
