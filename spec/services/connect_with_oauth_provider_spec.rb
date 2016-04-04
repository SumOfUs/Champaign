require 'rails_helper'

describe ConnectWithOauthProvider do
  let(:resp) { double(:resp, provider: 'google', uid: '1234', info: double(:info, email: 'foo@example.com' ) )}

  [[:user, User], [:member, Member]].each do |user_sym, user_class|

    context "#{user_sym} doesn't exist" do
      it "creates #{user_sym}" do
        expect{ ConnectWithOauthProvider.connect(resp, user_sym) }.to change{ user_class.count }.by 1
        expect(user_class.first.email).to eq('foo@example.com')
      end
    end

    context "#{user_sym} exists, but is disconnected" do
      let!(:user){ create user_sym, email: 'foo@example.com', password: 'password', password_confirmation: 'password' }

      it "updates #{user_sym}" do
        expect{ ConnectWithOauthProvider.connect(resp, user_sym) }.not_to change{ user_class.count }
        expect(user.reload.uid).to eq('1234')
      end
    end

    context "#{user_sym} already exists and is connected" do
      let!(:user){ create user_sym, email: 'foo@example.com', provider: 'google', uid: '1234'}

      it 'changes nothing' do
        expect{ ConnectWithOauthProvider.connect(resp, user_sym) }.not_to change{ user_class.count }
        expect( user_class.last).to eq user
      end
    end
  end

  describe 'whitelisting' do

    it 'whitelists domain' do
      Settings.oauth_domain_whitelist = %w(sumofus.org exxon.mobi)
      expect{ ConnectWithOauthProvider.connect(resp, :user) }.to raise_error(Champaign::NotWhitelisted)
    end

    it 'skips check when whitelist empty' do
      Settings.oauth_domain_whitelist = []
      expect{ ConnectWithOauthProvider.connect(resp, :user) }.not_to raise_error
    end

    it 'skips check when creating member' do
      Settings.oauth_domain_whitelist = %w(sumofus.org exxon.mobi)
      expect{ ConnectWithOauthProvider.connect(resp, :member) }.not_to raise_error
    end
  end
end
