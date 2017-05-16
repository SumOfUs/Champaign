# frozen_string_literal: true

class AddMemberCallEventsToCalls < ActiveRecord::Migration[4.2]
  def change
    add_column :calls, :member_call_events, :json, array: true, default: []
  end
end
