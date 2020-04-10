# frozen_string_literal: true

require 'csv'

namespace :replace_pension_funds_email do
  desc 'Find & replace email of PensionFunds as specified in the CSV file.'
  task now: :environment do
    puts 'Starting replace_pension_funds_email ...', ''
    path = Rails.root.join('lib', 'task_files', 'replace_pension_funds_email.csv').to_s
    csv_table = CSV.parse(File.read(path), headers: true)
    csv_table.each_with_index do |row, index|
      next unless row['Replace with']

      pension_fund = begin
                         PensionFund.find_by(email: row['Address'])
                     rescue StandardError
                       nil
                       end
      result = pension_fund.update(email: row['Replace with']) if pension_fund
      puts "Row #{index + 1} - Email #{pension_fund ? 'exists' : 'not found'}."
      puts "#{result ? 'Success' : 'Failed'} - #{row['Address']}", ''
    end
    puts '', '... replace_pension_funds_email is done.'
  end
end
