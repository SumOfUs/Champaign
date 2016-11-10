# frozen_string_literal: true
# == Schema Information
#
# Table name: member_authentications
#
#  id                     :integer          not null, primary key
#  member_id              :integer
#  password_digest        :string           not null
#  facebook_uid           :string
#  facebook_token         :string
#  facebook_token_expiry  :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  token                  :string
#  confirmed_at           :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#

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

  describe '#confirm' do
    subject { create(:member_authentication, confirmed_at: nil, token: '123') }

    before do
      subject.confirm
    end

    it 'sets confirmed_at' do
      expect(subject.confirmed_at).not_to be_nil
    end

    it 'deletes token' do
      expect(subject.token).to be_nil
    end
  end

  describe '#reset_password' do
    subject { create(:member_authentication, :confirmed, password: 'password', password_confirmation: 'password') }

    before do
      subject.reset_password('newpassword', 'newpassword')
    end

    it 'resets password' do
      expect(subject.authenticate('newpassword')).to be true
      expect(subject.authenticate('password')).to be false
    end
  end

  describe '#set_reset_password_token' do
    subject { create(:member_authentication) }

    before do
      subject.set_reset_password_token
    end

    it 'sets token and date' do
      expect(subject.reset_password_token).to match(/\w+/)
      expect(subject.reset_password_sent_at).not_to be_nil
    end
  end

  describe '.find_by_valid_reset_password_token' do
    let!(:authentication) { create(:member_authentication, :with_reset_password_token) }

    it 'returns record' do
      expect(MemberAuthentication.find_by_valid_reset_password_token('123')).to eq(authentication)
    end

    context 'when stale' do
      it 'returns nil' do
        Timecop.travel 2.days do
          expect(MemberAuthentication.find_by_valid_reset_password_token('123')).to be_nil
        end
      end
    end
  end

  describe '.find_by_email' do
    let(:member) { create(:member, email: 'test@example.com') }
    let!(:authentication) { create(:member_authentication, member: member) }

    it 'returns authentication for member with matching email' do
      expect(MemberAuthentication.find_by_email('test@example.com')).to eq(authentication)
    end
  end
end
