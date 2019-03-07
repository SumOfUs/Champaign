module CallTool::TwimlGenerator
  class Empty < Base
    def self.run
      Twilio::TwiML::VoiceResponse.new.to_s
    end
  end
end
