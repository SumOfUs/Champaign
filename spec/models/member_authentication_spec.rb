# frozen_string_literal: true
require 'rails_helper'

describe MemberAuthentication do
  let(:member) { create :member }
  let(:member_authentication) { create :member_authentication }

  context 'password authentication' do
    it 'creates a random password if no password is given' do
      authentication = MemberAuthentication.create(member: member)
      expect(authentication.password).to_not eq(nil)
      expect(authentication.password_digest).to be_a(String)
    end

    it 'should not change the password if it already has one' do
      authentication = MemberAuthentication.create(member: member)
      password_digest = authentication.password_digest
      MemberAuthentication.find(authentication.id).save
      expect(authentication.reload.password_digest).to eq(password_digest)
    end

    it 'is able to authenticate a password (via `has_secure_password`)' do
      password = 'valid_password'
      authentication = MemberAuthentication.create(
        member: member,
        password: password
      )
      expect(authentication.authenticate(password)).to eq(authentication)
      expect(authentication.authenticate('invalid_password')).to be(false)
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
