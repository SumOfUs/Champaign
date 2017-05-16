# frozen_string_literal: true

class ChangeColOnImage < ActiveRecord::Migration[4.2]
  def change
    add_column     :images, :created_at, :datetime
    add_column     :images, :updated_at, :datetime

    remove_column :images, :widget_id, :integer
    add_reference :images, :campaign_page, index: true
  end
end
