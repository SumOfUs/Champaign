# == Schema Information
#
# Table name: phone_numbers
#
#  id      :integer          not null, primary key
#  number  :string
#  country :string
#

class PhoneNumber < ActiveRecord::Base
  validates :number, presence: true, phony_plausible: true
  phony_normalize :number
end
