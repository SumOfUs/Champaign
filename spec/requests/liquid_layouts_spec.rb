require 'rails_helper'

RSpec.describe "LiquidLayouts", type: :request do
  describe "GET /liquid_layouts" do
    it "works! (now write some real specs)" do
      get liquid_layouts_path
      expect(response).to have_http_status(200)
    end
  end
end
