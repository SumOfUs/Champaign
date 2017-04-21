# frozen_string_literal: true

module BraintreeServices
  class PaymentOptions
    attr_reader :params

    def initialize(params, cookied_payment_methods)
      @params = params
      @cookied_payment_methods = cookied_payment_methods
    end

    def payment_method
      @payment_method ||= customer.payment_methods.find(params[:payment][:payment_method_id])

      raise PaymentProcessor::Exceptions::PaymentMethodNotFound unless @payment_method
      @payment_method
    end

    def valid_payment_method_id
      cookied_payment_methods.split(',').include?(params[:payment][:payment_method_id])
    end

    def payment_method_id
      return nil unless valid_payment_method_id
      return nil unless member&.customer

      member
        .customer
        .payment_methods
        .stored
        .active
        .where(token: params[:payment][:payment_method_id])
        .first
        &.id
    end

    def amount
      params[:payment][:amount]
    end

    def token
      payment_method.token
    end

    def merchant_account_id
      PaymentProcessor::Braintree::MerchantAccountSelector
        .for_currency(params[:payment][:currency])
    end

    def plan_id
      PaymentProcessor::Braintree::SubscriptionPlanSelector
        .for_currency(params[:payment][:currency])
    end

    def express_account?
      authentication.present?
    end

    def last_4
      case payment_method.instrument_type
      when 'paypal_account'
        'PYPL'
      else
        payment_method.last_4
      end
    end

    def currency
      params[:payment][:currency]
    end

    def customer
      @customer ||= member.try(:braintree_customer)
      raise PaymentProcessor::Exceptions::CustomerNotFound unless @customer
      @customer
    end

    def member
      @member ||= Member.find_by_email(params[:user][:email])
    end

    def authentication
      member.authentication
    end

    def page
      @page ||= Page.find(params[:page_id])
    end

    def subscription_options
      {
        payment_method_token: token,
        plan_id: plan_id,
        price: amount,
        merchant_account_id: merchant_account_id
      }
    end

    def recurring?
      ActiveRecord::Type::Boolean.new.type_cast_from_user(params[:payment][:recurring])
    end
  end
end
