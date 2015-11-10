class ActionUser < ActiveRecord::Base

  def self.find_from_request(akid: nil, id: nil)
    if akid.present?
      actionkit_user_id = AkidParser.parse(akid)[:actionkit_user_id]
      action_user = self.find_by(actionkit_user_id: actionkit_user_id)
      return action_user if action_user.present?
    end
    id.present? ? self.find_by(id: id) : nil
  end
end
