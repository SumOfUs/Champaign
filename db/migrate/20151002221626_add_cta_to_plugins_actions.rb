# frozen_string_literal: true

class AddCtaToPluginsActions < ActiveRecord::Migration[4.2]
  def change
    add_column :plugins_actions, :cta, :string
  end
end
