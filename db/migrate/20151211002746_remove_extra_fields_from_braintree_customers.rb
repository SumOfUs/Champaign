class RemoveExtraFieldsFromBraintreeCustomers < ActiveRecord::Migration
  def change
    change_table(:payment_braintree_customers) do |t|
      t.remove :card_type,
               :card_bin,
               :cardholder_name,
               :card_debit,
               :card_last_4,
               :card_unqiue_number_identifier,
               :email,
               :first_name,
               :last_name
    end
  end
end
