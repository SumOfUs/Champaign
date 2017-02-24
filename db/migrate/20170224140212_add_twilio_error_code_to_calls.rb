class AddTwilioErrorCodeToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :twilio_error_code, :integer
  end
end
