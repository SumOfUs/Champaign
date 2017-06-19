# frozen_string_literal: true

class AddSubscribedMemberToActions < ActiveRecord::Migration[4.2]
  def change
    add_column :actions, :subscribed_member, :boolean, default: true
  end
end
