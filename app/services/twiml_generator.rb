# frozen_string_literal: true
class TwimlGenerator
  def self.run(call)
    Twilio::TwiML::Response.new do |r|
      if call.sound_clip.present?
        r.Play ActionController::Base.new.view_context.asset_url call.sound_clip.url
      end
      r.Dial call.target_phone_number
    end.text
  end
end
