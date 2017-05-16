# frozen_string_literal: true

class AddFollowUpPlan < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :follow_up_plan, :integer, default: 0, null: false
    add_reference :pages, :follow_up_page, index: true
  end
end
