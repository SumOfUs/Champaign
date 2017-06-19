# frozen_string_literal: true

class AddDefaultToContentField < ActiveRecord::Migration[4.2]
  def change
    change_column :campaign_pages, :content, :text, default: ''
  end
end
