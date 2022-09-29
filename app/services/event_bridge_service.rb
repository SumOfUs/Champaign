class EventBridgeService
  attr_reader :options

  def initialize(options: default_options)
    @options = options
    @client = Aws::EventBridge::Client.new(
      region: @options[:region]
    )
  end

  def call(detail:, detail_type:)
    event_payload = define_event_hash(detail, detail_type)
    resp = client.put_events(entries: [event_payload])
    { events: resp.data.entries } if resp.data.failed_entry_count.zero?

    check_errors(resp.data.entries)
  end

  def check_errors(eventbridge_events)
    event_arr = []

    eventbridge_events.each do |entry|
      if entry.error_code.nil?
        event_arr << entry
        next
      end
      error_msg = "AWS events error code: #{entry.error_code}, message: #{entry.error_message}"
      Rails.logger.error(error_msg)
      event_arr << entry
    end

    { events: event_arr }
  end

  def define_event_hash(detail, detail_type)
    {
      time: Time.zone.now.to_s,
      source: options[:source],
      resources: [''],
      event_bus_name: options[:event_bus_name],
      detail: detail,
      detail_type: detail_type
    }
  end

  private

  attr_reader :client

  def default_options
    {
      region: 'us-east-1',
      event_bus_name: "PulpoEventBus-#{Settings.aws_secrets_manager_prefix}",
      source: 'sumofus.org/champaign'
    }
  end
end
