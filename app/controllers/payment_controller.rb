# frozen_string_literal: true

class PaymentController < ApplicationController
  skip_before_action :verify_authenticity_token

  def transaction
    if builder.success?
      process_and_render_success
    else
      render_errors
    end
  end

  def process_and_render_success
    write_member_cookie(builder.action.member_id) unless builder.action.blank?
    id = recurring? ? { subscription_id: builder.subscription_id } : { transaction_id: builder.transaction_id }

    if store_in_vault?
      result = BraintreeServices::PaymentResult.new(builder.result)

      existing_payment_methods = (cookies.signed[:payment_methods] || '').split(',')
      (existing_payment_methods << result.payment_method_token).uniq

      cookies.signed[:payment_methods] = {
        value: existing_payment_methods.join(','),
        expires: 1.year.from_now
      }
    end

    respond_to do |format|
      format.html { redirect_to follow_up_page_path(page) }
      format.json { render json: { success: true }.merge(id) }
    end
  end

  def render_errors
    @errors = client::ErrorProcessing.new(builder.error_container, locale: locale).process
    @page = page
    respond_to do |format|
      format.html { render 'payment/donation_errors', layout: 'member_facing' }
      format.json { render json: { success: false, errors: @errors }, status: 422 }
    end
  end

  def builder
    @builder ||= if recurring?
                   client::Subscription.make_subscription(payment_options)
                 else
                   client::Transaction.make_transaction(transaction_options)
                 end
  end

  private

  def recurring?
    @recurring ||= ActiveRecord::Type::Boolean.new.type_cast_from_user(params[:recurring])
  end

  def store_in_vault?
    @store_in_vault ||= ActiveRecord::Type::Boolean.new.type_cast_from_user(params[:store_in_vault]) || false
  end

  def page
    @page ||= Page.find(params[:page_id])
  end

  def locale
    page.try(:language).try(:code)
  end
end
