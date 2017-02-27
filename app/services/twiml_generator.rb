# frozen_string_literal: true
class TwimlGenerator
  class << self
    def run(call)
      Twilio::TwiML::Response.new do |r|
        if call.sound_clip.present?
          r.Play ActionController::Base.new.view_context.asset_url call.sound_clip.url
        end

        r.Dial action: action_url(call) do |d|
          set_number(d, call)
        end
      end.text
    end

    def action_url(call)
      Rails.application.routes.url_helpers.call_log_url(call)
    end

    def set_number(d, call)
      number = call.target_phone_number.split('ext')
      if number.length > 1
        d.Number number[0], sendDigits: number[1]
      else
        d.Number number[0]
      end
    end
  end
end
