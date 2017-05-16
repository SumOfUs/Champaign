module CallTool::TwimlGenerator
  class Start < Base
    def run
      Twilio::TwiML::Response.new do |r|
        r.Gather action: call_menu_url(call), numDigits: 1, timeout: 0 do
          if call.sound_clip.present?
            r.Play sound_clip_url
          end
        end
        r.Redirect call_menu_url(call)
      end.text
    end

    private

    def sound_clip_url
      call.sound_clip.url
    end
  end
end
