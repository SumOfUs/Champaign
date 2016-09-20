# frozen_string_literal: true

require 'rails_helper'

describe MemberAuthenticationBuilder do
  let!(:member) { create(:member, email: 'test@example.com') }
  let(:token) { SecureRandom.base64(24) }
  subject { MemberAuthenticationBuilder }

  describe '.build' do
    context 'with valid params' do
      subject do
        described_class.build(
          password: 'password',
          password_confirmation: 'password',
          email: 'test@example.com',
          language_code: 'EN'
        )
      end

      before do
        allow(SecureRandom).to receive(:base64).and_return(token)
      end

      it 'creates member authentication' do
        expect(subject).to be_valid
        expect(member.reload.authentication).to be
        expect(member.authentication.token).to eq token
      end
    end

    context 'with invalid params' do
      subject do
        described_class.build(
          password: 'password',
          password_confirmation: 'wrong',
          email: 'test@example.com',
          language_code: 'EN'
        )
      end

      it 'creates member authentication' do
        expect(subject).not_to be_valid
        expect(member.reload.authentication).to be nil
      end
    end
  end
end
