# frozen_string_literal: true

class CreateDonationBands < ActiveRecord::Migration[4.2]
  def change
    create_table :donation_bands do |t|
      t.string :name
      t.integer :amounts, array: true, default: []

      t.timestamps null: false
    end
  end
end
