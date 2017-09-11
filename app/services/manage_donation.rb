# frozen_string_literal: true

class ManageDonation
  def self.create(params:)
    ManageAction.create(params, extra_params: { donation: true })
  end
end
