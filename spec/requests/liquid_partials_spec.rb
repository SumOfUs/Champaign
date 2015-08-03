require 'rails_helper'

RSpec.describe "LiquidPartials", type: :request do
  describe "GET /liquid_partials" do
    it "works! (now write some real specs)" do
      get liquid_partials_path
      expect(response).to have_http_status(200)
    end
  end
end
