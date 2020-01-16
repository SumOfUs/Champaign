# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/confirmation_mailer
class ConfirmationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/confirmation_mailer/confirmation_email
  # ActionViewer::Base.preview_path is "/champaign/spec/mailers/previews"
  def confirmation_email
    ConfirmationMailer.confirmation_email(email: Faker::Internet.email, token: Faker::Crypto.md5)
  end
end
