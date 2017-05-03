class AddPhoneNumberToCallTools < ActiveRecord::Migration
  class Plugins::CallTools < ActiveRecord::Base; end
  class PhoneNumber < ActiveRecord::Base; end

  def up
    add_column :plugins_call_tools, :caller_phone_number_id, :integer
    caller_id = ENV['DEFAULT_CALLER_ID'] || Settings.calls&.default_caller_id
    if caller_id.present?
      phone_number = PhoneNumber.find_or_create_by!(number: caller_id)
      Plugins::CallTools.update_all(caller_phone_number_id: phone_number.id)
    end
  end

  def down
    remove_column :plugins_call_tools, :caller_phone_number_id
  end
end
