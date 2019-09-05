# frozen_string_literal: true

require 'rails_helper'

describe Recaptcha3 do
  include Rails.application.routes.url_helpers

  # rubocop:disable LineLength
  let(:valid_data) do
    { token: '03AOLTBLTx8PMg5ysKEN5nLmhzDad2lIHsf7rSVaDogDrChLL6hprN3nLFMjpvtr0FWewUDezV_SgV-YfUSU2yOyClXx6xaI4OxRsELoi4626iU31B4pdx3pCtcpNNBA8u1yB7IJxtpLM-E7_vdy7IfvS0YEB1758VVpxiJEbGTLmLb111SjTkFBWuhZ3XyrHFca-22uLzKpawc8RQ1-j57ZR3SMel4DCkNzveSWjYYH381z_MAY7Ev5Q7tK6_iEqrqUsgSt1wF-xtht5fLmjKXYkknPN3SB1_32mRl9BBuMzfIl6wO-GUnWhKbzEpsSlSqbEhljS_38GxViA3gC1eu5cOQWhKde56-EKYOG1JaTb8QiyamDoKKetITV8yWy8ZlmcspgD0Gv9B',
      action: 'donate/83' }
  end
  # rubocop:enable LineLength

  let(:invalid_data) do
    { token: nil, action: nil }
  end

  describe '.valid?' do
    context 'With invalid data' do
      subject { Recaptcha3.new(invalid_data) }

      it 'should return false' do
        expect(subject.valid?).to be_falsy
      end

      it 'should include all errors' do
        subject.valid?
        expect(subject.errors).to include("Token can't be blank")
        expect(subject.errors).to include("Action can't be blank")
      end
    end

    context 'With valid data' do
      subject { Recaptcha3.new(valid_data) }

      it 'should return true' do
        expect(subject.valid?).to be_truthy
      end

      it 'should not have any errors' do
        subject.valid?
        expect(subject.errors).to be_empty
      end
    end
  end

  describe '.human?' do
    context 'With invalid data' do
      subject { Recaptcha3.new(invalid_data) }

      it 'should return false' do
        expect(subject.human?).to be_falsy
      end

      it 'should include all errors' do
        subject.valid?
        expect(subject.errors).to include("Token can't be blank")
        expect(subject.errors).to include("Action can't be blank")
      end
    end

    context 'With valid data' do
      subject { Recaptcha3.new(valid_data) }

      it 'should return true and have no errors' do
        VCR.use_cassette('valid_captcha_service_req') do
          status = subject.human?
          expect(status).to be_truthy
          expect(subject.errors).to be_empty
        end
      end
    end

    context 'With low score response' do
      subject { Recaptcha3.new(valid_data) }

      it 'should return false' do
        VCR.use_cassette('valid_captcha_less_score') do
          expect(subject.human?).to be_falsy
        end
      end
    end

    context 'On Multiple submissions' do
      subject { Recaptcha3.new(valid_data) }

      it 'should return false' do
        VCR.use_cassette('valid_captcha_multiple_submit') do
          subject.human?
          expect(subject.errors).to include('timeout-or-duplicate')
        end
      end
    end
  end
end
