# frozen_string_literal: true

class RemoveUnusedThermometerBoolean < ActiveRecord::Migration[4.2]
  def change
    remove_column :pages, :thermometer
  end
end
