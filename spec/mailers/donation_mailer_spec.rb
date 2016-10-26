# frozen_string_literal: true
require "rails_helper"

RSpec.describe DonationMailer do
  describe 'subscription_email' do
    let(:mail) { DonationMailer.subscription_email(email: 'test@example.com', language: 'EN') }

    it 'renders the headers' do
      expect(mail.subject).to match(/Your recurring donation with SumOfUs/)
      expect(mail.to).to eq(['test@example.com'])
      expect(mail.from).to eq(['info@example.com'])
    end

    describe 'HTML body' do
      subject { mail.html_part.body.to_s }

      it 'renders relevant text and link to the subscription page' do
        expect(subject).to include("charges on your recurring donations have not been going through recently, and we've therefore cancelled the subscription")
        #TODO: assertion for subscription page link
      end
    end

    describe 'Plain text body' do
      subject { mail.text_part.body.to_s }

      it 'renders relevant text and URL to the subscription page' do
        expect(subject).to include("charges on your recurring donations have not been going through recently, and we&#39;ve therefore cancelled the subscription")
        #TODO: assertion for subscription page url
      end
    end
  end
end
