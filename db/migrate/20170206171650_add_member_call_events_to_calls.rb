# frozen_string_literal: true
class AddMemberCallEventsToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :member_call_events, :json, array: true, default: []
  end
end
