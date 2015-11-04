class Action < ActiveRecord::Base
  belongs_to :page
  belongs_to :action_user
  after_create :update_page_action_count

  def update_page_action_count
    page.increment! :action_count
  end
end
