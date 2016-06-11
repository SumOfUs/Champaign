require 'rails_helper'

describe "api/members" do

  def json
    JSON.parse(response.body)
  end

  subject do
    post api_members_path, email: "newbie@test.org"
  end

  describe 'POST api/members' do

    let!(:existing_member) { create :member, email: "oldie@test.org"}

    it "creates a new member" do
      expect{subject}.to change {Member.count}.by(1)
      expect(Member.last.email).to eq("newbie@test.org")
    end

    it "doesn't explode if a member with the given email already exists" do
      expect(Member.find_by(email: existing_member.email)).to eq existing_member
      expect { post api_members_path, email: existing_member.email }.to_not change {Member.count}
    end

    it "posts a message on the AK worker queue to create a new user in AK" do
      allow(Member).to receive(:create!).and_return(existing_member)
      allow(existing_member).to receive(:send_to_ak)
      subject
      expect(existing_member).to have_received(:send_to_ak)
    end
  end

end