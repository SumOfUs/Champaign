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
    Action.create({
      action_user: action_user,
      campaign_page: campaign_page
    })
  end

  private

  def previous_action
    Action.where(action_user: action_user, campaign_page_id: @params[:campaign_page_id]).first
  end

  def campaign_page
    @page ||= CampaignPage.find(@params[:campaign_page_id])
  end

  def action_user
    @user ||= ActionUser.find_by(email: @params[:email]) || ActionUser.create(email: @params[:email])
  end
end
