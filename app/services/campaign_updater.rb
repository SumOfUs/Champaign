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
    detail_type = 'campaignUpdatedOnChampaign'
    detail = {
      name: @campaign.name,
      id: @campaign.id
    }
    EventBridgeService.new
      .call(detail: detail.to_json,
            detail_type: detail_type)
  rescue StandardError => e
    puts "Error while trying to put campaignUpdatedOnChampaign event on pulpo event bus: #{e.message}."
    {}
  end
end
