# == Schema Information
#
# Table name: registered_email_addresses
#
#  id    :bigint(8)        not null, primary key
#  email :string
#  name  :string
#

class RegisteredEmailAddress < ActiveRecord::Base
  validates :email, presence: true, email: true

  before_validation { email.try(:downcase!) }
end
