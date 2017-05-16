# frozen_string_literal: true

class AddAnalyticsToShareButton < ActiveRecord::Migration[4.2]
  def change
    add_column :share_buttons, :analytics, :text
  end
end
