# frozen_string_literal: true
require 'rails_helper'

describe MemberAuthentication do
  describe 'on create' do
    it 'has token set' do
      auth = create(:member_authentication)

      expect(auth.token.length).to eq(32)
    end
  end

  describe 'validation' do
    it 'requires matching passwords' do
      authentication = build(:member_authentication, password: 'random', password_confirmation: '')
      expect(authentication).to be_invalid
      expect(authentication.errors[:password_confirmation].size).to eq(1)
    end

    context 'member' do
      it 'must be unique' do
        authentication = create(:member_authentication)
        member = authentication.member
        other_authentication = build(:member_authentication, member: member)

        expect(other_authentication).to be_invalid
        expect(other_authentication.errors[:member_id].size).to eq(1)
      end

      it 'must be present' do
        authentication = build(:member_authentication, member: nil)
        expect(authentication).to be_invalid
        expect(authentication.errors[:member_id].size).to eq(1)
      end
    end
  end

  context 'password authentication' do
    subject { create(:member_authentication, confirmed_at: Time.now) }

    it 'is able to authenticate a password (via `has_secure_password`)' do
      expect(subject.authenticate('password')).to be(true)
      expect(subject.authenticate('invalid_password')).to be(false)
    end
  end

  context 'facebook authentication' do
    let(:authentication) { create :member_authentication }

    describe '#facebook_oauth' do
      it 'has a uid' do
        expect(authentication.facebook_oauth).to include(:uid)
      end

      it 'has an oauth_token' do
        expect(authentication.facebook_oauth).to include(:oauth_token)
      end

      it 'has a oauth_token_expiry' do
        expect(authentication.facebook_oauth).to include(:oauth_token_expiry)
      end
    end
  end
end
