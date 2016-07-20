class Action < ActiveRecord::Base
  belongs_to :page, counter_cache: :action_count
  belongs_to :member

  has_paper_trail on: [:update, :destroy]

  after_create :update_member_donor_status

  def update_member_donor_status
    return unless donation
    return if member.recurring_donor?
    form_data['is_subscription'] ? member.recurring_donor! : member.donor!
  end
end

