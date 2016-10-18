# frozen_string_literal: true

require 'rails_helper'

describe MemberWithAuthentication do
  let(:valid_params) do
    {
      name: 'Foo',
      email: 'test@example.com',
      password: 'password',
      password_confirmation: 'password',
      country: 'DE'
    }
  end

  context 'valid params' do
    it 'creates a member' do
      MemberWithAuthentication.create(valid_params)

      expect(Member.first.email).to eq('test@example.com')
    end

    it 'creates valid authentication' do
      MemberWithAuthentication.create(valid_params)

      expect(Member.first.authentication).to be_kind_of(MemberAuthentication)
    end

    context 'existing member' do
      it 'creates authentication' do
        member = create(:member, email: 'test@example.com')
        params = valid_params.merge(email: 'test@example.com')

        MemberWithAuthentication.create(params)
        expect(member.authentication).not_to be nil
      end
    end
  end

  context 'with errors' do
    it 'on blank email' do
      builder = MemberWithAuthentication.create(valid_params.except(:email))
      expect(builder.errors[:email].first).to eq("can't be blank")
    end

    it 'on non-matching passwords' do
      params = valid_params.merge(password: 'somethingelse')
      builder = MemberWithAuthentication.create(params)

      expect(builder.errors[:password].first).to eq("don't match")
    end

    it 'on too short a password' do
      params = valid_params.merge(password: '123', password_confirmation: '123')
      builder = MemberWithAuthentication.create(params)

      expect(builder.errors[:password].first).to eq('is too short (minimum is 6 characters)')
    end

    it 'on existing authentication' do
      authentication = create(:member_authentication)
      params = valid_params.merge(email: authentication.member.email)
      builder = MemberWithAuthentication.create(params)

      expect(builder.errors[:authentication].first).to eq('already exists')
    end
  end
end
