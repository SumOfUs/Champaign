module CallTool
  module CallStatus
    TIME_OUT_THRESHOLD = 15.seconds

    # Returns one of: connecting, ringing, answered, completed, timed_out
    def self.for(call)
      status = call.member_call_events.last&.[]('CallStatus')

      if status.present?
        status
      elsif Time.now < call.created_at + TIME_OUT_THRESHOLD
        'connecting'
      else
        'timed_out'
      end
    end
  end
end
