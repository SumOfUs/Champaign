class AddConsentedAtToMembers < ActiveRecord::Migration[5.1]
  def change
    add_column :members, :consented_at, :datetime
  end
end
