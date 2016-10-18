# frozen_string_literal: true
require 'rails_helper'

describe ConfirmationMailer do
  describe 'confirmation_email' do
    let(:mail) { ConfirmationMailer.confirmation_email(email: 'test@example.com', token: '123', language: 'EN') }

    it 'renders the headers' do
      expect(mail.subject).to match(/Confirm your account/)
      expect(mail.to).to eq(['test@example.com'])
      expect(mail.from).to eq(['info@example.com'])
    end

    describe 'HTML body' do
      subject { mail.html_part.body.to_s }

      it 'has a thank you message' do
        expected = /Thank you for registering/

        expect(subject).to match(expected)
      end

      it 'has confirmation link' do
        expected = /email_confirmation\?email=test%40example.com&amp;language=EN&amp;token=123/

        expect(subject).to match(expected)
      end
    end

    describe 'Plain text body' do
      subject { mail.text_part.body.to_s }

      it 'has a thank you message' do
        expected = /Thank you for registering/

        expect(subject).to match(expected)
      end

      it 'has confirmation link' do
        expected = /email_confirmation\?email=test%40example.com&amp;language=EN&amp;token=123/

        expect(subject).to match(expected)
      end
    end
  end
end
