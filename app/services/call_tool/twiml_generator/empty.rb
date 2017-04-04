module CallTool::TwimlGenerator
  class Empty < Base
    def self.run
      Twilio::TwiML::Response.new.text
    end
  end
end
