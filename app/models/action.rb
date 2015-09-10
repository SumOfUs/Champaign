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
    Action.find_or_create_by( action_user: action_user, campaign_page: page ) do |action|
      action.form_data = @params
    end
  end

  private

  def previous_action
    Action.where(action_user: action_user, campaign_page_id: page).first
  end

  def action_user
    @user ||= ActionUser.find_or_create_by(email: @params[:email])
  end

  def page
    @campaign_page ||= CampaignPage.find(@params[:campaign_page_id])
  end
end
