# frozen_string_literal: true

module PaymentBraintreeService
  extend self

  def payment_methods_for_member(member)
    customer(member).payment_methods.order('created_at desc')
  end

  def payment_method_for_member(member:, id:)
    customer(member).payment_methods.find(id)
  end

  def customer(member)
    Payment::Braintree::Customer.find_by!(member_id: member.id)
  end
end

module Api
  module Stateless
    module Braintree
      class PaymentMethodsController < StatelessController
        before_filter :authenticate_request!

        def index
          @payment_methods = PaymentBraintreeService.payment_methods_for_member(@current_member)
        end

        def destroy
          @payment_method = PaymentBraintreeService.payment_method_for_member(member: @current_member, id: params[:id])

          result = begin
                     ::Braintree::PaymentMethod.delete(@payment_method.token)
                   rescue ::Braintree::NotFoundError
                     @payment_method.destroy
                   end


          @payment_method.destroy if result.success?
          render json: { success: true }
        end
      end
    end
  end
end
