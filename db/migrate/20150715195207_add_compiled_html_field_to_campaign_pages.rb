# frozen_string_literal: true

class AddCompiledHtmlFieldToCampaignPages < ActiveRecord::Migration[4.2]
  def change
    add_column :campaign_pages, :compiled_html, :text
  end
end
