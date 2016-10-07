# frozen_string_literal: true

module BraintreeServices
  class PaymentOptions
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def payment_method
      @payment_method ||= customer.payment_methods.find(params[:payment][:payment_method_id])
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

    def currency
      params[:payment][:currency]
    end

    def customer
      @customer ||= member.braintree_customer
    end

    def member
      @member ||= Member.find_by(email: params[:user][:email])
    end

    def authentication
      member.authentication
    end

    def page
      @page = Page.find(params[:page_id])
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
