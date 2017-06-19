# frozen_string_literal: true

class RemoveLanguageIdNullConstraint < ActiveRecord::Migration[4.2]
  def change
    change_column :campaign_pages, :language_id, :integer, null: true
  end
end
