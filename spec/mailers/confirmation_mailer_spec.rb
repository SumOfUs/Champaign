# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ConfirmationMailer, type: :mailer do
  describe 'confirmation_email' do
    let(:member) { create(:member,
                          email: 'test@example.com',
                          authentication: create(:member_authentication,
                                                 password: 'password',
                                                 token: 'imarealtoken1235')) }

    let(:mail) { ConfirmationMailer.confirmation_email(member) }

    it 'renders the headers' do
      expect(mail.subject).to eq('E-mail confirmation for signing up for express donations with SumOfUs')
      expect(mail.to).to eq(['test@example.com'])
      expect(mail.from).to eq([Settings.default_mailer_address])
    end

    it 'renders the HTML body' do
      expect(mail.body.encoded).to include("<html><body><h1>Thank you for your donation!</h1><p>To confirm your \
enrollment in our express donations plan, visit this \
<a href=\"#{Settings.home_page_url}/email_confirmation?email=test%40example.com&amp;token=imarealtoken1235\">link</a>\
, or copy paste this URL to your browser: #{Settings.home_page_url}/\
email_confirmation?email=test%40example.com&amp;token=imarealtoken1235 </p></body></html>")
    end

    it 'renders the plaintext body' do
      expect(mail.body.encoded).to include("To confirm your enrollment in our express donations plan, visit this\
 address: #{Settings.home_page_url}/email_confirmation?email=test%40example.com&amp;token=imarealtoken1235' ")
    end
  end
end
