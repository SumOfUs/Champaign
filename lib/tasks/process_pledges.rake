# frozen_string_literal: true

namespace :champaign do
  desc 'Settle pledged payments for a specific page'
  task :process_pledges, [:page_id] => :environment do |_task, args|
    page = Page.find(args[:page_id])
    transactions = Payment::Braintree::Transaction.where(page_id: page.id)
    puts "Processing #{transactions.size} transactions"
    transactions.each do |transaction|
      log_id = "Transaction #{transaction.id} #{transaction.transaction_id}"
      begin
        if !transaction.pledge
          puts "Skipping #{log_id}: it's not a pledge"
        elsif transaction.pledge_processed_at.present?
          puts "Skipping #{log_id}: already processed"
        else
          resp = ::Braintree::Transaction.submit_for_settlement(transaction.transaction_id)

          if resp.success?
            transaction.update(pledge_processed_at: Time.now)
            puts "#{log_id} processed successfully"
          else
            puts "#{log_id} failed with #{resp.message}"
          end
        end
      rescue Exception => e
        puts "#{log_id} errored out with #{e}"
      end
    end
  end
end
