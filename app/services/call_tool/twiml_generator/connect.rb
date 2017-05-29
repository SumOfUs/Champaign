module CallTool::TwimlGenerator
  class Connect < Base
    def run
      Twilio::TwiML::Response.new do |r|
        r.Dial action: target_call_status_url(call), callerId: call.caller_id do |dial|
          dial.Number(call.target.phone_number, dial_options)
        end
      end.text
    end

    private

    def dial_options
      extension = call.target.phone_extension
      extension.present? ? { sendDigits: extension } : {}
    end
  end
end
