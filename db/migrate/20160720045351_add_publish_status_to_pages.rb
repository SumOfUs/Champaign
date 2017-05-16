# frozen_string_literal: true

class AddPublishStatusToPages < ActiveRecord::Migration[4.2]
  class Page < ActiveRecord::Base
  end

  def up
    add_column :pages, :publish_status, :integer, default: 1, null: false
    add_index :pages, :publish_status
    Page.where(active: true).update_all(publish_status: 0)
    Page.where(active: false).update_all(publish_status: 1)
    remove_column :pages, :active
  end

  def down
    add_column :pages, :active, :boolean, default: false
    add_index  :pages, :active
    remove_column :pages, :publish_status
  end
end
