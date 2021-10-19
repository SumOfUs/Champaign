class LocalPaymentTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :local_payment_transactions do |t|
      t.string :payment_id
      t.jsonb :data
      t.string :page_id
      t.timestamps
      t.index ['payment_id'], name: 'index_local_payment_transactions_on_payment_id'
    end
  end
end
