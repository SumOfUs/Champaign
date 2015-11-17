class Payment::BraintreeTransaction < ActiveRecord::Base
  def self.write_transaction(sale)
    create(transaction_id: sale.transaction.id)
  end
end
