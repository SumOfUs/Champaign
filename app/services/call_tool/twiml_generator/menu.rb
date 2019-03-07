module CallTool::TwimlGenerator
  class Menu < Base
    def run
      case digit
      when '1'
        render_redirect_to call_connect_url(call)
      when '2'
        render_redirect_to call_start_url(call)
      else
        render_menu
      end
    end

    private

    def render_redirect_to(url)
      Twilio::TwiML::VoiceResponse.new do |r|
        r.redirect url
      end.to_s
    end

    def render_menu
      Twilio::TwiML::VoiceResponse.new do |r|
        r.gather action: call_menu_url(call), numDigits: 1, timeout: 10 do |gather|
          if call.menu_sound_clip.present?
            gather.play url: menu_sound_clip_url
          else
            gather.say message: text_to_speach_message, voice: 'alice', language: call.page.language_code
          end
        end
        r.redirect call_menu_url(call)
      end.to_s
    end

    def menu_sound_clip_url
      call.menu_sound_clip.url
    end

    def text_to_speach_message
      I18n.t('call_tool.text_to_speach_menu', locale: call.page.language_code)
    end

    def digit
      @params['Digits']
    end
  end
end
