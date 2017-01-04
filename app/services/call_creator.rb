class CallCreator
  def initialize(params)
    @params = params
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

    @call.persisted?
  end

  def errors
    @call.errors.messages
  end

  private

  def place_call
    client = Twilio::REST::Client.new.account.calls
    client.create(
      :from => Settings.calls.default_caller_id,
      :to => @call.member_phone_number,
      #TODO move host config out of here
      :url => Rails.application.routes.url_helpers.call_twiml_url(@call, host: Settings.host)
    )
  end
end
