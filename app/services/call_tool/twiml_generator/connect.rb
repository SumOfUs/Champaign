module CallTool::TwimlGenerator
  class Connect < Base
    def run
      Twilio::TwiML::VoiceResponse.new do |r|
        r.dial action: target_call_status_url(call), callerId: call.caller_id do |dial|
          dial.number(call.target.phone_number, dial_options)
        end
      end.to_s
    end

    private

    def dial_options
      extension = call.target.phone_extension
      extension.present? ? { sendDigits: extension } : {}
    end
  end
end
