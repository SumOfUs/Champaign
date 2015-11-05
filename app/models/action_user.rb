class ActionUser < ActiveRecord::Base

  def self.find_action_user_from_request(akid, cookie_id)
    action_user = self.find_by(actionkit_user_id: AkidParser.parse(akid)[:actionkit_user_id])
    if action_user and akid
      # We don't allow returns when there's no AKID because
      # that field isn't required, so a nil AKID would return
      # lots of users, which we don't want.
      action_user
    elsif cookie_id
      begin
        ActionUser.find(cookie_id)
      rescue ActiveRecord::RecordNotFound
        nil
      end
    else
      nil
    end
  end
end
