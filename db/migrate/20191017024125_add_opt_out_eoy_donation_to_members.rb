class AddOptOutEoyDonationToMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :opt_out_eoy_donation, :integer, default: 0
    add_index :members, :opt_out_eoy_donation
  end
end
