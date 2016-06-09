require 'rails_helper'

describe "api/members" do

  def json
    JSON.parse(response.body)
  end

  describe 'POST api/members' do
    let(:new_member) { build :member, email: "newbie@test.org" }

    it 'creates a new member' do
      expect { post api_members_path(:email => new_member.email) }.to change {Member.count}.by(1)
      expect (Member.last.email).to be(new_member.email)
      expect(Member.last.email).to eq(new_member.email)
    end
  end

end