module CallTool::TwimlGenerator
  class Menu < Base
    def run
      case digit
      when '1'
        render_redirect_to call_connect_url(call)
      when '2'
        render_redirect_to call_start_url(call)
      else
        render_menu(@params['iterator'].to_i)
      end
    end

    private

    def render_redirect_to(url)
      Twilio::TwiML::VoiceResponse.new do |r|
        r.redirect url
      end.to_s
    end

    def render_menu(iterator)
      # if iterator is 3 or more, terminate the call
      iteration = iterator.blank? ? 0 : iterator
      return terminate_call if iteration >= 3

      Twilio::TwiML::VoiceResponse.new do |r|
        r.gather action: call_menu_url(call), numDigits: 1, timeout: 10 do |gather|
          if call.menu_sound_clip.present?
            gather.play url: menu_sound_clip_url
          else
            gather.say message: text_to_speach_message, voice: 'alice', language: call.page.language_code
          end
        end
        # increment the iterator and play the menu again
        r.redirect call_menu_url(call, Digits: digit, iterator: iteration + 1)
      end.to_s
    end

    def terminate_call
      Twilio::TwiML::VoiceResponse.new do |r|
        r.say message: termination_message, voice: 'alice', language: call.page.language_code
        r.hangup
      end.to_s
    end

    def termination_message
      I18n.t('call_tool.termination_message', locale: call.page.language_code)
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
