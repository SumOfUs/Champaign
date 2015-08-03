class ChangeColOnImage < ActiveRecord::Migration
  def change
    add_column     :images, :created_at, :datetime
    add_column     :images, :updated_at, :datetime

    remove_column :images, :widget_id, :integer
    add_reference :images, :campaign_page, index: true
  end
end
