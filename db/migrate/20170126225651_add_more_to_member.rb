# frozen_string_literal: true

class AddMoreToMember < ActiveRecord::Migration[4.2]
  def change
    add_column :members, :more, :jsonb
  end
end
