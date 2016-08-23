# frozen_string_literal: true
class AddAnalyticsToShareButton < ActiveRecord::Migration
  def change
    add_column :share_buttons, :analytics, :text
  end
end
