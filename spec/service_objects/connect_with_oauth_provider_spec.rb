require 'rails_helper'

describe ConnectWithOauthProvider do
  let(:resp) { double(:resp, provider: 'google', uid: '1234', info: double(:info, email: 'foo@example.com' ) )}

  context "user doesn't exist" do
    it "creates user" do
      ConnectWithOauthProvider.connect(resp)
      expect(User.first.email).to eq('foo@example.com')
    end
  end

  context "user exists, but is disconnected" do
    #TODO: Replace with factory
    let!(:user){ User.create!( email: 'foo@example.com', password: 'password', password_confirmation: 'password') }

    it "updates user" do
      ConnectWithOauthProvider.connect(resp)
      expect(user.reload.uid).to eq('1234')
    end
  end
end
