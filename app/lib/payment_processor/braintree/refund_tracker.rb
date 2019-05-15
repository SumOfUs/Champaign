# Filter past 6 months refunds and update them in db
module PaymentProcessor
  module Braintree
    class RefundTransactionInfo
      # refunded_transaction_id - here denotes the original
      # transaction which is refunded
      FIELDS = %w[
        id status type amount created_at updated_at
        refunded_transaction_id
      ].freeze
      def initialize(transaction)
        @transaction = transaction
      end

      def to_h
        return {} unless @transaction.present?

        FIELDS.collect { |field| { field.to_sym => @transaction.send(field) } }.reduce({}, :merge)
      end
    end

    class RefundTracker
      def initialize(start_date: '')
        @start_date = start_date
      end

      def sync
        unsynced_transactions.each do |t|
          transaction = Payment::Braintree::Transaction.find_by(transaction_id: t[:refunded_transaction_id])
          transaction&.update_attributes(refund: true, refund_transaction_id: t[:id])
        end
      end

      def unsynced_ids
        (refund_ids - synced_ids)
      end

      def refund_ids
        @refund_ids ||= begin
         result = ::Braintree::Transaction.search do |search|
           search.type.is 'credit'
           search.refund.is true
         end
         result.present? ? result.ids : []
       end
      end

      def unsynced_transactions
        return [] unless unsynced_ids.present?

        @unsynced_transactions ||= begin
          transactions = []
          unsynced_ids.each do |transaction_id|
            transaction = ::Braintree::Transaction.find(transaction_id)
            transactions << RefundTransactionInfo.new(transaction).to_h
          end
          transactions
        end
      end

      def synced_ids
        @synced_ids ||= Payment::Braintree::Transaction
          .where(refund_transaction_id: refund_ids, refund: true)
          .pluck(:refund_transaction_id)
      end
    end
  end
end
