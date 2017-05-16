class AddPhoneNumberToCallTools < ActiveRecord::Migration[4.2]
  def up
    add_column :plugins_call_tools, :caller_phone_number_id, :integer
  end

  def down
    remove_column :plugins_call_tools, :caller_phone_number_id
  end
end
