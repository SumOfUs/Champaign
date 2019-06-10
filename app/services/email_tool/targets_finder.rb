# frozen_string_literal: true

class EmailTool::TargetsFinder
  def initialize(postcode:, endpoint:)
    @endpoint = endpoint
    @postcode = postcode
  end

  def find
    resp = HTTParty.get(targets_endpoint)
    targets = JSON.parse(resp.body)
    format_targets(targets)
  end

  private

  def targets_endpoint
    URI.join(@endpoint.to_s, @postcode.strip).to_s
  end

  def format_targets(targets)
    targets.map do |target|
      {
        name: "#{target['first_name']} #{target['last_name']}",
        email: target['email_1']
      }
    end
  end
end
