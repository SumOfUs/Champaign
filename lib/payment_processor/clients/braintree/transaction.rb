module PaymentProcessor
  module Clients
    module Braintree
      class Transaction

        def self.make_transaction(nonce:, amount:, user:)
          new(nonce, amount, user).sale
        end

        def initialize(nonce, amount, user)
          @amount = amount
          @nonce = nonce
          @user = user

          find_or_create_donor

        end

        def find_or_create_donor
          # Work in progress / brainstorming some ideas. There are no specs for this yet. I'm just thinking.
          # This isn't getting called anywhere at this point, but @donor is used in sale.

          # check ActionUsers / Members table and find braintree_customer_id from the member associated
          # with the e-mail address
          # if no member is associated with that e-mail address, create member.
          # Please revise this - we do member recognition elsewhere
          @donor = ActionUser.find_by(email: @user[:email]) || ActionUser.create!(@user)
          # if the braintree_customer_id is blank, create a vault user, auto-generating the id.
          if @donor.braintree_customer_id.blank?
            result = PaymentProcessor::Clients::Braintree::Customer.create(@user)
            if result.success?
              # save the auto-generated customer_id to the donor
              @donor.braintree_customer_id = result.customer.id
              @donor.save
            else
              # TODO: handle error - vault customer creation failed
            end
          end
        end

        def sale
          ::Braintree::Transaction.sale(
            amount: @amount,
            payment_method_nonce: @nonce,
            options: {
              submit_for_settlement: true,
              store_in_vault_on_success: true
            },
            customer_id: @donor.braintree_customer_id
          )
        end

      end
    end
  end
end
