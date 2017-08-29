# == Schema Information
#
# Table name: registered_email_addresses
#
#  id    :integer          not null, primary key
#  email :string
#

class RegisteredEmailAddress < ActiveRecord::Base
  validates :email, presence: true, email: true

  before_validation { email.try(:downcase!) }
end
