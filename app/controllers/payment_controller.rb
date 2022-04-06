# frozen_string_literal: true

class PaymentController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :localize_from_page_id, only: :transaction
  before_action :authenticate_user!, only: :generate_cookie
  before_action :clear_payment_completed_cookie, only: [:transaction]

  def generate_cookie
    @email = params[:email]

    @customer = Payment::Braintree::Customer.find_by(email: @email) if @email.to_s.match?(/sumofus.org/)

    unless @customer.nil?
      payment_method = @customer.payment_methods.last

      set_facebook_pixel_user_id(@customer.member.id)

      cookies.signed[:member_id] = {
        value: @customer.member.id,
        expires: 1.day.from_now,
        domain: :all
      }

      cookies.signed[:payment_methods] = {
        value: payment_method.token,
        expires: 1.day.from_now,
        domain: :all
      }
    end
  end

  def transaction
    if builder.success?
      process_and_render_success
    else
      render_errors
    end
  end

  def local_payment_transaction
    opts = {
      payment_id: params[:paymentId],
      data: params[:data],
      page_id: params[:page_id]
    }

    resp = Payment::Braintree::LocalPaymentTransaction.create(opts)
    render json: resp
  end

  def process_and_render_success
    write_member_cookie(builder.action.member_id) unless builder.action.blank?

    if store_in_vault?
      result = BraintreeServices::PaymentResult.new(builder.result)

      existing_payment_methods = (cookies.signed[:payment_methods] || '').split(',')
      existing_payment_methods << result.payment_method_token

      @payment_method_obj = Payment::Braintree::PaymentMethod.find_by_token(result.payment_method_token).attributes

      cookies.signed[:payment_methods] = {
        value: existing_payment_methods.uniq.join(','),
        expires: 1.year.from_now,
        domain: :all
      }
    end

    respond_to do |format|
      format.html do
        set_payment_completed_cookie
        redirect_to follow_up_page_path(page, payment: 'completed')
      end
      format.json do
        render json: {
          success: true,
          payment_method: @payment_method_obj,
          tracking: FacebookPixel.completed_registration_hash(page: page, action: builder.action)
        }.merge(follow_up).merge(id_for_response)
      end
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
                   client::Transaction.make_transaction(payment_options)
                 end
  end

  private

  # For tracking gocardless payment complete action
  # in client side
  def set_payment_completed_cookie
    data = [params[:page_id], params[:amount], params[:currency],
            (recurring? ? 'recurring' : 'non_recurring')].join('-')
    cookies['__gc_pay'] = data
  end

  def clear_payment_completed_cookie
    cookies.delete('__gc_pay')
  end

  def recurring?
    @recurring ||= ActiveRecord::Type::Boolean.new.cast(params[:recurring])
  end

  def store_in_vault?
    (ActiveRecord::Type::Boolean.new.cast(params[:store_in_vault]) || false) && provider_not_gc
  end

  def provider_not_gc
    params[:provider] != 'GC'
  end

  def page
    @page ||= Page.find(params[:page_id])
  end

  def locale
    page.try(:language).try(:code)
  end

  def follow_up
    follow_up_params = params[:user].merge(member_id: builder.action.member_id).to_unsafe_hash
    follow_up_url = PageFollower.new_from_page(page, follow_up_params).follow_up_path
    { follow_up_url: follow_up_url }
  end

  def id_for_response
    if recurring?
      { subscription_id: builder.subscription_id }
    else
      { transaction_id: builder.transaction_id }
    end
  end
end
