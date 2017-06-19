class AddTwilioErrorCodeToCalls < ActiveRecord::Migration[4.2]
  def change
    add_column :calls, :twilio_error_code, :integer
  end
end
