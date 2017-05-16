# frozen_string_literal: true

class RenameCampaignPageToPage < ActiveRecord::Migration[4.2]
  def change
    rename_column :actions, :campaign_page_id, :page_id
    rename_column :campaign_pages_tags, :campaign_page_id, :page_id
    rename_column :images, :campaign_page_id, :page_id
    rename_column :links, :campaign_page_id, :page_id
    rename_column :plugins_actions, :campaign_page_id, :page_id
    rename_column :plugins_thermometers, :campaign_page_id, :page_id
    rename_column :share_buttons, :campaign_page_id, :page_id
    rename_column :share_emails, :campaign_page_id, :page_id
    rename_column :share_twitters, :campaign_page_id, :page_id
    rename_column :share_facebooks, :campaign_page_id, :page_id

    rename_table :campaign_pages_tags, :pages_tags
    rename_table :campaign_pages, :pages
  end
end
