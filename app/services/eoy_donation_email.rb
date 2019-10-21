class EoyDonationEmail
  include ActiveModel::Validations

  OPT_OUT_EOD_DONATION = 1
  OPT_IN_EOD_DONATION = 0

  attr_accessor :member

  validates :member, presence: true
  validate :verify_member_actionkit_user_id

  def initialize(member)
    @member = member
  end

  def opt_out
    opt_in_or_out(OPT_OUT_EOD_DONATION)
  end

  def opt_in
    opt_in_or_out(OPT_IN_EOD_DONATION)
  end

  private

  def actionkit_user_id
    member.try(:actionkit_user_id)
  end

  def verify_member_actionkit_user_id
    return unless member

    errors.add(:base, 'member does not have actionkit id') && (return false) unless actionkit_user_id
    true
  end

  def opt_in_or_out(option)
    return false unless valid?

    synced = false

    Member.transaction do
      if member.update(opt_out_eoy_donation: option)
        synced = sync_with_action_kit
        raise(ActiveRecord::Rollback) && (return false) unless synced
      end
    end
    synced
  end

  def sync_with_action_kit
    begin
      data = { fields: { opt_out_eoy_donation: member.opt_out_eoy_donation } }
      resp = ActionKitConnector.client.update_user(member.actionkit_user_id, data)
      status = resp.try(:code) == 204
    rescue StandardError => e
      Rails.logger.info "Error occurred while syncing opt_out_eoy_donation field. #{e.inspect}"
      status = false
    end

    errors.add(:base, 'Error syncing with actionkit') && (return false) unless status
    true
  end
end
