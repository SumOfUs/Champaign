class EoyDonationEmail
  include ActiveModel::Validations

  OPT_OUT_EOD_DONATION = 1
  OPT_IN_EOD_DONATION = 0

  attr_reader :akid, :actionkit_user_id

  validates :akid, presence: true
  validates :actionkit_user_id, presence: true

  def initialize(akid)
    @akid = akid
    set_actionkit_user_id
  end

  def opt_out
    opt_in_or_out(OPT_OUT_EOD_DONATION)
  end

  def opt_in
    opt_in_or_out(OPT_IN_EOD_DONATION)
  end

  def member
    return nil unless actionkit_user_id

    @member ||= Member.find_by(actionkit_user_id: actionkit_user_id)
  end

  def confirmation_email_matched?(email)
    info = fetch_user_info
    return false unless info.present?

    info['email'].to_s.downcase == email.to_s.downcase
  end

  private

  def set_actionkit_user_id
    @actionkit_user_id ||= AkidParser.parse(@akid, Settings.action_kit.akid_secret)[:actionkit_user_id]
  end

  def opt_in_or_out(option)
    return false unless valid?

    updated_actionkit = update_action_kit(option)
    member.update(opt_out_eoy_donation: option) if member && updated_actionkit
    updated_actionkit
  end

  def fetch_user_info
    return {} unless actionkit_user_id.present?

    begin
      resp = ActionKit::Client.get("user/#{actionkit_user_id}", params: {})
      return {} unless resp.code == 200

      return resp.parsed_response
    rescue StandardError => e
      Rails.logger.info "Error occurred while fetching actionkit user details. #{e.inspect}"
      return {}
    end
  end

  def update_action_kit(option)
    begin
      data = { fields: { opt_out_eoy_donation: option } }
      resp = ActionKitConnector.client.update_user(actionkit_user_id, data)
      status = resp.try(:code) == 204
    rescue StandardError => e
      Rails.logger.info "Error occurred while updating actionkit opt_out_eoy_donation field. #{e.inspect}"
      status = false
    end
    errors.add(:base, 'Error updating actionkit') && (return false) unless status
    status
  end
end
