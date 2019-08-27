# == Schema Information
#
# Table name: sessions_blacklists
#
#  id         :bigint(8)        not null, primary key
#  sessionid  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_sessions_blacklists_on_sessionid  (sessionid)
#

FactoryBot.define do
  factory :sessions_blacklist do
    sessionid { 'MyString' }
  end
end
