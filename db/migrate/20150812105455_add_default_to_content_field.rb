# frozen_string_literal: true
class AddDefaultToContentField < ActiveRecord::Migration
  def change
    change_column :campaign_pages, :content, :text, default: ''
  end
end
