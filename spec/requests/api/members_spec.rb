require 'rails_helper'

describe "api/members" do

  def json
    JSON.parse(response.body)
  end

  describe 'POST api/members' do

    it 'creates a new member' do
      post api_member_path(:email => "newbie@test.org")
    end
  end

end