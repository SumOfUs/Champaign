require 'rails_helper'

describe 'Omniauth with Devise' do
  def login_with_google(email = 'cesar@sumofus.org')
    login_with_oauth2(:google_oauth2, {
      uid:      '12345',
      provider: 'google_oauth2',
      info: {
        email: email
      }
    })
  end

  before do
    ChampaignConfig.yaml_location = './spec/fixtures/champaign.yml'
  end

  after do
    ChampaignConfig.reset!
  end

  subject(:user) { User.first }

  context 'new user' do
    before(:each) { login_with_google }

    it 'creates account' do
      expect(user.uid).to eq('12345')
      expect(user.provider).to eq('google_oauth2')
      expect(user.email).to eq('cesar@sumofus.org')
    end
  end

  context 'existing user' do
    let!(:existing_user) { User.create(email: 'cesar@sumofus.org', password: 'password', password_confirmation: 'password')}

    it 'updates accounts' do
      expect{
        login_with_google
      }.to change{ existing_user.reload.provider }.from(nil).to('google_oauth2')
    end
  end

  context 'not whitelisted' do
    it 'redirects home' do
      login_with_google('not@whitelisted.com')
      expect(response).to redirect_to(root_path)
      expect(flash.now[:alert]).to eq("You're not authorised to authenticate with that account.")
    end
  end
end

