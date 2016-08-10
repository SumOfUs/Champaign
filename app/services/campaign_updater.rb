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
      if success
        publish_event
      end
    end
  end

  private

  def publish_event
    ChampaignQueue.push({
      type: 'update_campaign',
      name: @campaign.name,
      campaign_id: @campaign.id
    })
  end
end
