# frozen_string_literal: true
class RemoveLanguageIdNullConstraint < ActiveRecord::Migration
  def change
    change_column :campaign_pages, :language_id, :integer, null: true
  end
end
