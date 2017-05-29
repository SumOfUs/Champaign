# == Schema Information
#
# Table name: phone_numbers
#
#  id      :integer          not null, primary key
#  number  :string
#  country :string
#

FactoryGirl.define do
  factory :phone_number do
    number {
      ['+448008085422', '+448000119722', '+61261885422', '+13437003422'].sample
    }
  end
end
