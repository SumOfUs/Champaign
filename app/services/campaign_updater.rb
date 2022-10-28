# frozen_string_literal: true

class CampaignUpdater
  def self.run(campaign, params)
    new(campaign, params).run
  end

  def initialize(campaign, params)
    @campaign = campaign
    @params = params
  end

  def run
    @campaign.update(@params).tap do |success|
      publish_event if success
    end
  end

  private

  def publish_event
    ChampaignQueue.push(
      { type: 'update_campaign',
        name: @campaign.name,
        campaign_id: @campaign.id },
      { group_id: "campaign:#{@campaign.id}" }
    )
  end
end
