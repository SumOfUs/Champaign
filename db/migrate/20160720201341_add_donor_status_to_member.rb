# frozen_string_literal: true

class AddDonorStatusToMember < ActiveRecord::Migration[4.2]
  def change
    add_column :members, :donor_status, :integer, null: false, default: 0
  end
end
