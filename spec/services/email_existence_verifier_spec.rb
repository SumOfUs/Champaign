# frozen_string_literal: true

require 'rails_helper'

describe EmailExistenceVerifier do
  context 'empty data' do
    subject { EmailExistenceVerifier.new('') }

    it 'should return false' do
      expect(subject.valid?).to be_falsy
    end

    it 'should have errors' do
      subject.valid?
      expect(subject.errors.full_messages).to include "Email can't be blank"
    end
  end

  context 'valid and existing email account' do
    subject { EmailExistenceVerifier.new('support@sumofus.org') }

    it 'should return true' do
      VCR.use_cassette('email_existence_verifier_valid_email') do
        expect(subject.exist?).to be_truthy
        expect(subject.errors.full_messages).to be_empty
        expect(subject.remaining_validations).to eql 994
      end
    end
  end

  context 'valid domain and non existing email account' do
    subject { EmailExistenceVerifier.new('tessdfsdfsffffsfsdfsfsfsf@gmail.com') }

    it 'should return false' do
      VCR.use_cassette('email_existence_verifier_valid_domain_non_existing_account') do
        expect(subject.exist?).to be_falsy
        expect(subject.errors.full_messages).to include('Invalid email / email account does not exist')
        expect(subject.remaining_validations).to eql 991
      end
    end
  end

  context 'non existing domain and non existing email account' do
    subject { EmailExistenceVerifier.new('tessdfsd@sadadadadasdad.com') }

    it 'should return false' do
      VCR.use_cassette('email_existence_verifier_non_exiting_domain_non_existing_account') do
        expect(subject.exist?).to be_falsy
        expect(subject.errors.full_messages).to include('Invalid email / email account does not exist')
      end
    end
  end

  context 'error in connecting api' do
    subject { EmailExistenceVerifier.new('support@sumofus.org') }

    it 'should return false' do
      VCR.use_cassette('email_existence_verifier_exception') do
        expect(subject.exist?).to be_falsy
        expect(subject.errors.full_messages).to include('Unable to validate email')
      end
    end
  end

  context 'exception in parsing api' do
    before do
      allow(HTTParty).to receive(:post).and_raise('Exception')
    end

    subject { EmailExistenceVerifier.new('support@sumofus.org') }

    it 'should return false' do
      VCR.use_cassette('email_existence_verifier_exception') do
        expect(subject.exist?).to be_falsy
        expect(subject.errors.full_messages).to include('Unable to validate email')
      end
    end
  end
end
