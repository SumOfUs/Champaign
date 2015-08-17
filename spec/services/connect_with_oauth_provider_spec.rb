require 'rails_helper'

describe ConnectWithOauthProvider do
  let(:resp) { double(:resp, provider: 'google', uid: '1234', info: double(:info, email: 'foo@example.com' ) )}
  let(:whitelist) { %w(example.com) }

  before do
    allow(ChampaignConfig).to receive(:oauth_domain_whitelist){ whitelist }
  end

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

  describe 'whitelisting' do
    let(:whitelist) { %w(sumofus.org exxon.mobi) }

    it 'whitelists domain' do
      expect{ ConnectWithOauthProvider.connect(resp) }.to raise_error(Champaign::NotWhitelisted)
    end

    context 'empty whitelist' do
      let(:whitelist) { [] }

      it 'skips check' do
        expect{ ConnectWithOauthProvider.connect(resp) }.to_not raise_error
      end
    end
  end
end
