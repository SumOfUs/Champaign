class AddFormToFundraiser < ActiveRecord::Migration
  def change
    add_reference :plugins_fundraisers, :form, index: true, foreign_key: true
  end
end
