# frozen_string_literal: true

class AddFormToFundraiser < ActiveRecord::Migration[4.2]
  def change
    add_reference :plugins_fundraisers, :form, index: true, foreign_key: true
  end
end
