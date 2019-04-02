# == Schema Information
#
# Table name: registered_target_endpoints
#
#  id          :bigint(8)        not null, primary key
#  description :text
#  name        :string
#  url         :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class RegisteredTargetEndpoint < ApplicationRecord
  validates :url, presence: true
  validates :name, presence: true

  def self.all_for_select
    RegisteredTargetEndpoint.all.map { |e| [e.name, e.id] }
      .unshift(['Global Pension Funds', ''])
  end
end
