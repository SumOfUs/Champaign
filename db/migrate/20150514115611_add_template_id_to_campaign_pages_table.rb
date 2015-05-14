class AddTemplateIdToCampaignPagesTable < ActiveRecord::Migration
  def change
    add_column :campaign_pages, :template_id, :integer
  end
end


