require 'rails_helper'

describe 'Omniauth with Devise' do
  def login_with_google
    login_with_oauth2(:google_oauth2, {
      uid:      '12345',
      provider: 'google_oauth2',
      info: {
        email: 'cesar@example.com'
      }
    })
  end

  subject(:user) { User.first }

  context 'new user' do
    before(:each) { login_with_google }

    it 'creates account' do
      expect(user.uid).to eq('12345')
      expect(user.provider).to eq('google_oauth2')
      expect(user.email).to eq('cesar@example.com')
    end
  end

  context 'existing user' do
    let!(:existing_user) { User.create(email: 'cesar@example.com', password: 'password', password_confirmation: 'password')}
    before do
    end

    it 'updates accounts' do
      expect{
        login_with_google
      }.to change{ existing_user.reload.provider }.from(nil).to('google_oauth2')
    end
  end
end

