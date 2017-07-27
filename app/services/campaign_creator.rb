# frozen_string_literal: true

class CampaignCreator
  def self.run(params)
    new(params).run
  end

  def initialize(params)
    @params = params
  end

  def run
    @campaign = Campaign.create(@params)
    publish_event if @campaign.persisted?
    @campaign
  end

  private

  def publish_event
    ChampaignQueue.push(
      { type: 'create_campaign',
        name: @campaign.name,
        campaign_id: @campaign.id },
      { group_id: "campaign:#{@campaign.id}" }
    )
  end
end
