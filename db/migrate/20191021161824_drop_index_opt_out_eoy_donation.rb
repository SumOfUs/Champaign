class DropIndexOptOutEoyDonation < ActiveRecord::Migration[5.2]
  def up
    remove_index :members, :opt_out_eoy_donation
  end

  def down
    add_index :members, :opt_out_eoy_donation
  end
end
