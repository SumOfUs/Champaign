class Action < ActiveRecord::Base
  belongs_to :campaign_page
  belongs_to :action_user


  class << self
    def create_action(params)
      ManageAction.new(params).create
    end
  end
end


class ManageAction

  def initialize(params)
    @params = params
  end

  def create
    return if user_has_already_taken_action

    Action.create({
      action_user: action_user,
      campaign_page: page,
      form_data: @params
    })
  end

  private

  def user_has_already_taken_action
    Action.exists? action_user: action_user
  end

  def previous_action
    Action.where(action_user: action_user, campaign_page_id: page).first
  end

  def action_user
    @user ||= ActionUser.find_by(email: @params[:email]) || ActionUser.create(email: @params[:email])
  end

  def page
    @campaign_page ||= CampaignPage.find(@params[:campaign_page_id])
  end
end
