class Action < ActiveRecord::Base
  belongs_to :page
  belongs_to :action_user

end

