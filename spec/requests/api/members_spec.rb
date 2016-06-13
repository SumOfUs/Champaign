require 'rails_helper'

describe "api/members" do

  def json
    JSON.parse(response.body)
  end

  subject do
    post api_members_path, email: "newbie@test.org", country: "NZ", postal: "1A943", name: "Anahera Parata"
  end

  describe 'POST api/members' do

    let!(:existing_member) { create :member, email: "oldie@test.org", name: "Oldie Goldie", country: "SWE", postal: 12880}

    it "creates a new member" do
      expect{subject}.to change {Member.count}.by(1)
      expect(Member.last.email).to eq("newbie@test.org")
      expect(Member.last.country).to eq("NZ")
      expect(Member.last.name).to eq("Anahera Parata")
      expect(Member.last.postal).to eq("1A943")
    end

    it "doesn't explode if a member with the given email already exists" do
      expect(Member.find_by(email: existing_member.email)).to eq existing_member
      expect { post api_members_path, email: existing_member.email }.to_not change {Member.count}
    end

    it "posts a message on the AK worker queue to create a new user in AK" do
      allow(Member).to receive(:create!).and_return(existing_member)
      allow(ChampaignQueue).to receive (:push)
      subject
      expect(ChampaignQueue).to have_received(:push).with(
        type: 'create_member',
        params: {
          email: existing_member.email,
          name: existing_member.name,
          country: existing_member.country,
          postal: existing_member.postal,
        }
      )
    end

    it "creates a new member also if the only field we get is an email address" do
      expect { post api_members_path, email: "private@email.com" }.to change {Member.count}.by(1)
      expect(Member.last.email).to eq("private@email.com")
      expect(Member.last.country).to be nil
      expect(Member.last.name).to eq ""
      expect(Member.last.postal).to be nil
    end
  end

end