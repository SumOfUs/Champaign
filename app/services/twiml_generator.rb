class TwimlGenerator
  def self.run(call)
    Twilio::TwiML::Response.new do |r|
      r.Say "Let's save the bees!"
      r.Dial call.target_phone_number
    end.text
  end
end
