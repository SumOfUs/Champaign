class Action < ActiveRecord::Base
  belongs_to :page
  belongs_to :member
  after_create :update_page_action_count
  has_paper_trail on: [:update, :destroy]

  def update_page_action_count
    page.increment! :action_count
  end
end
