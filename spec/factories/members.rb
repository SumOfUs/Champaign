# frozen_string_literal: true

# == Schema Information
#
# Table name: members
#
#  id                   :integer          not null, primary key
#  address1             :string
#  address2             :string
#  city                 :string
#  consented            :boolean
#  consented_updated_at :datetime
#  country              :string
#  donor_status         :integer          default("nondonor"), not null
#  email                :string
#  first_name           :string
#  last_name            :string
#  more                 :jsonb
#  opt_out_eoy_donation :integer          default(0)
#  postal               :string
#  title                :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  actionkit_user_id    :string
#
# Indexes
#
#  index_members_on_actionkit_user_id  (actionkit_user_id)
#  index_members_on_email              (email)
#  index_members_on_email_and_id       (email,id)
#

FactoryBot.define do
  factory :member do
    email { Faker::Internet.email }
    actionkit_user_id { Faker::Number.number(10) }
  end
end
