class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :email_address
      t.string :actionkit_member_id
    end
  end
end
