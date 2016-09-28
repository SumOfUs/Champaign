# frozen_string_literal: true
require 'rails_helper'

describe AuthTokenVerifier do
  subject { AuthTokenVerifier.new('a_token') }

  describe '#verify' do
    context 'with matching unconfirmed record' do
      let!(:member_authentication) { create(:member_authentication, token: 'a_token') }

      it 'is successful' do
        subject.verify
        expect(subject.success?).to be(true)
      end

      it 'confirms member authentication' do
        expect { subject.verify }
          .to change { member_authentication.reload.confirmed_at }.from(nil)
      end
    end

    context 'with matching confirmed record' do
      let!(:member_authentication) { create(:member_authentication, confirmed_at: Time.now, token: 'a_token') }

      it 'is unsuccessful' do
        subject.verify
        expect(subject.success?).to be(false)
      end

      it 'does not recomfirm member authentication' do
        expect { subject.verify }
          .not_to change { member_authentication.reload.confirmed_at }
      end

      it 'returns error' do
        subject.verify
        expect(subject.errors.first).to match(/already been confirmed/)
      end
    end

    context 'with no matching record' do
      it 'is unsuccessful' do
        subject.verify
        expect(subject.success?).to be(false)
      end

      it 'returns error' do
        subject.verify
        expect(subject.errors.first).to match(/[Nn]o account was found/)
      end
    end
  end
end
