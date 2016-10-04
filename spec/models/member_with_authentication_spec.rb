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
    before do
      MemberWithAuthentication.create(valid_params)
    end

    it 'creates a member' do
      expect(Member.first.email).to eq('test@example.com')
    end

    it 'creates valid authentication' do
      expect(Member.first.authentication).to be_kind_of(MemberAuthentication)
    end
  end

  context 'invalid params' do
    context 'invalid member' do
      subject do
        MemberWithAuthentication.create(valid_params.except(:email))
      end

      describe 'errors' do
        it 'on email' do
          expect(subject.errors[:email].first).to eq("can't be blank")
        end
      end
    end
  end
end
