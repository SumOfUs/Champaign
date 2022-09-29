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
    detail_type = 'campaignCreatedOnChampaign'
    detail = {
      name: @campaign.name,
      id: @campaign.id
    }
    EventBridgeService.new
      .call(detail: detail.to_json,
            detail_type: detail_type)
  rescue StandardError => e
    puts "Error while trying to put campaignCreatedOnChampaign event on pulpo event bus: #{e.message}."
    {}
  end
end
