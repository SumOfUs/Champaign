# frozen_string_literal: true

class ManageDonation
  def self.create(params:, extra_params: {})
    ManageAction.create(params, extra_params: { donation: true }.merge(extra_params.clone))
  end
end
