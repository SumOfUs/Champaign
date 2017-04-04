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
      Twilio::TwiML::Response.new do |r|
        r.Redirect url
      end.text
    end

    def render_menu
      Twilio::TwiML::Response.new do |r|
        r.Gather action: call_menu_url(call), numDigits: 1, timeout: 10 do
          if call.menu_sound_clip.present?
            r.Play menu_sound_clip_url
          else
            r.Say text_to_speach_message, voice: 'alice', language: call.page.language_code
          end
        end
        r.Redirect call_menu_url(call)
      end.text
    end

    def menu_sound_clip_url
      ActionController::Base.new.view_context.asset_url call.menu_sound_clip.url
    end

    def text_to_speach_message
      I18n.t('call_tool.text_to_speach_menu', locale: call.page.language_code)
    end

    def digit
      @params['Digits']
    end
  end
end
