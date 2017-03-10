# frozen_string_literal: true
class TwimlGenerator
  include Rails.application.routes.url_helpers

  attr_reader :call

  def self.run(call)
    new(call).run
  end

  def initialize(call)
    @call = call
  end

  class StartCall < TwimlGenerator
    def run
      Twilio::TwiML::Response.new do |r|
        r.Gather action: call_connect_url(call), finishOnKey: '0-9', timeout: 15 do
          if call.sound_clip.present?
            r.Play sound_clip_url
          else
            r.Say text_to_speach_message, voice: 'alice', language: call.page.language_code
          end
        end
      end.text
    end

    private

    def text_to_speach_message
      I18n.t('call_tool.press_key_to_connect', locale: call.page.language_code)
    end

    def sound_clip_url
      ActionController::Base.new.view_context.asset_url call.sound_clip.url
    end
  end

  class ConnectCall < TwimlGenerator
    def run
      Twilio::TwiML::Response.new do |r|
        r.Dial action: call_log_url(call) do |dial|
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
