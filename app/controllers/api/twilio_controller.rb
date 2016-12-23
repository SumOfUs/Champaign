class Api::TwilioController < ApplicationController
  # FIXME
  skip_before_action :verify_authenticity_token
  def index
    render xml: <<-eos
      <?xml version="1.0" encoding="UTF-8"?>
      <Response>
          <Say>Hello Monkey</Say>
      </Response>
    eos
  end
end
