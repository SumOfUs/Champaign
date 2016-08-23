# frozen_string_literal: true
class AddFeaturedPagesColumn < ActiveRecord::Migration
  def change
    # updates existing records after with the default value
    change_column_default :pages, :featured, false
  end
end
