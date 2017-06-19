# frozen_string_literal: true

class FixUniqueNumberIdentifier < ActiveRecord::Migration[4.2]
  def change
    rename_column :payment_braintree_customers, :card_unqiue_number_identifier, :card_unique_number_identifier
  end
end
