# frozen_string_literal: true
class AddDefaultFollowUpLayoutId < ActiveRecord::Migration
  def change
    add_reference :liquid_layouts, :default_follow_up_layout
  end
end
