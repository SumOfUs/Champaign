class CallCreator
  def self.run(params)
    new(params).run
  end

  def initialize(params)
    @params = params
  end

  def run
    page = Page.find(@params[:page_id])
    @call = Call.new(page: page,
                     member_id: @params[:member_id],
                     member_phone_number: @params[:phone],
                     target_id: @params[:target_id])
    if @call.save
      place_call
    end
    @call
  end

  private

  def find_call_tool(page_id)
    Plugins::CallTool.find_by_page_id(page_id) ||
      raise(ActiveRecord::RecordNotFound)
  end

  def place_call
    client = Twilio::REST::Client.new

    client.account.calls.create(
      :from => Settings.calls.default_caller_id,
      :to => @call.member_phone_number,
      #TODO move host config out of here
      :url => Rails.application.routes.url_helpers.call_twiml_url(@call, host: Settings.host)
    )
  end

end
