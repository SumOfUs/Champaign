# frozen_string_literal: true

class Api::BackgroundServicesController < ActionController::Base
  before_action :check_api_key

  # Fetch last 6 month refund records and sync with
  # payment_braintree_transactions table
  def sync_braintree_refunds
    tracker = PaymentProcessor::Braintree::RefundTracker.new
    tracker.sync
    render json: { refund_ids_synced: tracker.unsynced_ids }, status: :ok
  end

  protected

  def check_api_key
    return head :forbidden unless valid_api_key?
  end

  def valid_api_key?
    request.headers['X-Api-Key'] == Settings.api_key
  end
end
