# frozen_string_literal: true
class AddCompiledHtmlFieldToCampaignPages < ActiveRecord::Migration
  def change
    add_column :campaign_pages, :compiled_html, :text
  end
end
