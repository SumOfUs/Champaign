# frozen_string_literal: true

namespace :champaign do
  desc 'Settle pledged payments for a specific page'
  task :process_pledges, [:page_id] => :environment do |_task, args|
    Payment::Braintree::Transaction.where(page_id: args[:page_id]).each do |transaction|
      resp = ::Braintree::Transaction.submit_for_settlement(transaction.transaction_id)

      if resp.success?
        transaction.update(pledge_processed_at: Time.now)
      end
    end
  end
end
