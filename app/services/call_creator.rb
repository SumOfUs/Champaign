# frozen_string_literal: true
class CallCreator
  include Rails.application.routes.url_helpers

  def initialize(params)
    @params = params.clone
    @errors = {}
  end

  def run
    sanitize_params!
    page = Page.find(@params[:page_id])
    @call = Call.new(page: page,
                     member_id: @params[:member_id],
                     member_phone_number: @params[:member_phone_number],
                     target_index: target_index)
    Call.transaction do
      place_call if @call.save
    end

    errors.blank?
  end

  def errors
    @call.errors.messages.clone.tap do |e|
      @errors.each do |key, val|
        e[key] ||= []
        e[key] += val
      end
    end
  end

  private

  def sanitize_params!
    if @params[:member_phone_number].present?
      @params[:member_phone_number] = Phony.normalize(@params[:member_phone_number])
    end
  rescue Phony::NormalizationError
  end

  # TODO: Move method to service class, handle error messages in there.
  def place_call
    client = Twilio::REST::Client.new.account.calls
    client.create(
      from: Settings.calls.default_caller_id,
      to: @call.member_phone_number,
      url: call_twiml_url(@call),
      status_callback: call_event_url(@call),
      status_callback_method: 'POST',
      status_callback_event: %w(ringing answered completed)
    )
  rescue Twilio::REST::RequestError => e
    # 13223: Dial: Invalid phone number format
    # 13224: Dial: Invalid phone number
    # 13225: Dial: Forbidden phone number
    # 13226: Dial: Invalid country code
    # 21211: Invalid 'To' Phone Number
    # 21214: 'To' phone number cannot be reached
    @call.update!(twilio_error_code: e.code)
    if (e.code >= 13_223 && e.code <= 13_226) || [21_211, 21_214].include?(e.code)
      @errors[:member_phone_number] ||= []
      @errors[:member_phone_number] << I18n.t('call_tool.errors.phone_number.cant_connect')
    else
      Rails.logger.error("Twilio Error: API responded with code #{e.code} for #{@call.attributes.inspect}")
      @errors[:base] ||= []
      @errors[:base] << I18n.t('call_tool.errors.unknown')
    end
  end

  def target_index
    Integer(@params[:target_index])
  rescue
    @errors[:base] << I18n.t('call_tool.errors.unknown')
    0
  end
end
