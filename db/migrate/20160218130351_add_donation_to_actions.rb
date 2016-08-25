# frozen_string_literal: true
class AddDonationToActions < ActiveRecord::Migration
  def change
    add_column :actions, :donation, :boolean, default: false
  end
end
