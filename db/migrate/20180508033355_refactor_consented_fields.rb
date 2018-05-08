class RefactorConsentedFields < ActiveRecord::Migration[5.1]
  class Member < ApplicationRecord; end
  def up
    rename_column :members, :consented_at, :consented_updated_at
    add_column    :members, :consented, :boolean
    Member.where.not(consented_updated_at: nil).in_batches.each do |relation|
      relation.update_all(consented: true)
    end
  end

  def down
    rename_column :members, :consented_updated_at, :consented_at
    remove_column :members, :consented
  end
end
