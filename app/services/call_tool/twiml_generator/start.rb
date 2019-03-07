module CallTool::TwimlGenerator
  class Start < Base
    def run
      Twilio::TwiML::VoiceResponse.new do |r|
        r.gather action: call_menu_url(call), numDigits: 1, timeout: 0 do
          r.play sound_clip_url if call.sound_clip.present?
        end
        r.redirect call_menu_url(call)
      end.to_s
    end

    private

    def sound_clip_url
      call.sound_clip.url
    end
  end
end
