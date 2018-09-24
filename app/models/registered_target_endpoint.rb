class RegisteredTargetEndpoint < ApplicationRecord
  # validates :url, presence: true, name: true

  def self.all_for_select
    RegisteredTargetEndpoint.all.map { |e| [e.name, e.id] }
      .unshift(['Global Pension Funds', ''])
  end
end
