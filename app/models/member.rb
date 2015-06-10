class Member < ActiveRecord::Base
  has_paper_trail

  validates_presence_of :email_address, :actionkit_member_id
  # validates that e-mail is valid
  validates_format_of :email_address, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
end
