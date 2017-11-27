# frozen_string_literal: true

# Updates local donations resources to reflect the changes made to them through the member services portal
class MemberServicesDonationsUpdater
  attr_reader :resource, :errors, :status

  def initialize(params)
    # This is the resource ID from Braintree or GoCardless, not the ID of the local record
    @id = params[:id]
    @payment_provider = params[:provider]
  end

  def cancel
    @resource = assign_provider::Subscription.find_by(recurring_field_name)

    unless @resource
      @errors = ["Recurring donation #{id} for #{@payment_provider} not found."]
      @status = 404
      return false
    end

    if @resource.update(cancelled_at: Time.now)
      return true
    else
      @errors = ["Updating cancelled recurring donation failed on Champaign for #{@payment_provider} donation #{id}."]
      @status = 422
      return false
    end
  end

  private

  def assign_provider
    @assign_provider ||= @payment_provider == 'braintree' ? Payment::Braintree : Payment::GoCardless
  end

  def recurring_field_name
    # Returns { subscription_id: @id } for braintree and { go_cardless_id: @id } for GoCardless
    field_name = @payment_provider == 'braintree' ? 'subscription_id' : 'go_cardless_id'
    Hash[field_name.to_sym, @id]
  end
end
