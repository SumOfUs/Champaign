class Action < ActiveRecord::Base
  belongs_to :campaign_page
  belongs_to :action_user


  class << self
    def create_action(params)
      ManageAction.new(params).create
    end
  end
end
