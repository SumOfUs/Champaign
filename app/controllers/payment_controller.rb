class PaymentController < ApplicationController
  skip_before_action :verify_authenticity_token

  def transaction
    builder = if recurring?
      client::Subscription.make_subscription(payment_options)
    else
      client::Transaction.make_transaction(payment_options)
    end

    if builder.success?
      write_member_cookie(builder.action.member_id) unless builder.action.blank?
      id = recurring? ? { subscription_id: builder.subscription_id } : { transaction_id: builder.transaction_id }

      render json: { success: true }.merge(id)
    else
      errors = client::ErrorProcessing.new(builder.result).process
      render json: { success: false, errors: errors }, status: 422
    end
  end

  private

  def recurring?
    @recurring ||= ActiveRecord::Type::Boolean.new.type_cast_from_user( params[:recurring] )
  end
end
