# frozen_string_literal: true

require 'rails_helper'

describe AkidParser do
  subject { AkidParser }

  context 'valid akids' do
    let(:valid_akids) { ['1234.5678.tKK7gX', '.5678.hIdbLl', '64gd53.4325.Ivqznz'] }

    context 'with correct secret' do
      it 'returns populated response' do
        valid_akids.each do |akid|
          mailing, user = akid.split('.')

          expect(
            subject.parse(akid, 'secret_sauce')
          ).to include(actionkit_user_id: user, mailing_id: mailing)
        end
      end
    end

    context 'with tampered secret' do
      it 'returns unpopulated response' do
        valid_akids.each do |akid|
          expect(
            subject.parse(akid, 'ketchup')
          ).to include(actionkit_user_id: nil, mailing_id: nil)
        end
      end
    end
  end

  context 'invalid akids' do
    let(:akids_bad_hash) { ['1234.5678.bad', '.5678.', '64gd53.4325'] }
    let(:crazy_akids) { ['123123', '', nil, '3232.3123.12312.3234234'] }

    it 'returns unpopulated response' do
      crazy_akids.each do |akid|
        expect(
          subject.parse(akid, 'kethcup')
        ).to include(actionkit_user_id: nil, mailing_id: nil)
      end

      akids_bad_hash.each do |akid|
        expect(
          subject.parse(akid, 'kethcup')
        ).to include(actionkit_user_id: nil, mailing_id: nil)
      end
    end
  end
end
