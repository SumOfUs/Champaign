# frozen_string_literal: true
class AddDonorStatusToMember < ActiveRecord::Migration
  def change
    add_column :members, :donor_status, :integer, null: false, default: 0
  end
end
