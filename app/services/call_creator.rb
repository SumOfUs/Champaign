class CallCreator
  def initialize(params)
    @params = params
    @errors = {}
  end

  def run
    page = Page.find(@params[:page_id])
    @call = Call.new(page: page,
                     member_id: @params[:member_id],
                     member_phone_number: @params[:member_phone_number],
                     target_index: @params[:target_index])
    if @call.save
      place_call
    end

    errors.blank?
  end

  def errors
    @call.errors.messages.tap do |e|
      @errors.each do |key, val|
        e[key] ||= []
        e[key] += val
      end
    end
  end

  private

  #TODO Move method to service class, handle error messages in there.
  def place_call
    client = Twilio::REST::Client.new.account.calls
    client.create(
      :from => Settings.calls.default_caller_id,
      :to => @call.member_phone_number,
      #TODO move host config out of here
      :url => Rails.application.routes.url_helpers.call_twiml_url(@call, host: Settings.host)
    )
  rescue Twilio::REST::RequestError => e
    # 13223: Dial: Invalid phone number format
    # 13224: Dial: Invalid phone number
    # 13225: Dial: Forbidden phone number
    # 13226: Dial: Invalid country code
    # 21211: Invalid 'To' Phone Number
    # 21214: 'To' phone number cannot be reached
    if (e.code >= 13223 && e.code <= 13226) || [21211, 21214].include?(e.code)
      @errors[:member_phone_number] ||= []
      @errors[:member_phone_number] << "is invalid" #TODO: add translation
    else
      raise e
    end
  end
end
