module CallTool::TwimlGenerator
  class Connect < Base
    def run
      Twilio::TwiML::Response.new do |r|
        r.Dial action: target_call_status_url(call), callerId: call.caller_id do |dial|
          dial.Number(*number_params)
        end
      end.text
    end

    private

    def number_params
      number = call.target_phone_number.split('ext')
      options = number.length > 1 ? { sendDigits: number[1] } : {}
      [number[0], options]
    end
  end
end
