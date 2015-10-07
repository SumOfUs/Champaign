require 'rails_helper'

describe ActionKit::Helper do
  before do
    ENV['AK_PASSWORD'] = 'ak_password'
    ENV['AK_USERNAME'] = 'ak_username'
  end

  describe "#check_petition_name_is_available" do
    before do
      response_body_happy = { meta: { total_count: 0 } }
      response_body_sad = { meta: { total_count: 1 } }

      stub_request(:get, "https://ak_username:ak_password@act.sumofus.org/rest/v1/petitionpage/?_limit=1&name=foo-bar").
        to_return(status: 200, body: response_body_happy.to_json )

      stub_request(:get, "https://ak_username:ak_password@act.sumofus.org/rest/v1/petitionpage/?_limit=1&name=i-already-exist").
        to_return(status: 200, body: response_body_sad.to_json )
    end

    it "returns true when name is available" do
      expect(
        ActionKit::Helper.check_petition_name_is_available( 'foo-bar' )
      ).to be true
    end

    it "returns false when name isn't available" do
      expect(
        ActionKit::Helper.check_petition_name_is_available( 'i-already-exist' )
      ).to be false
    end
  end
end

