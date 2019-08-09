# frozen_string_literal: true
# rubocop:disable all

module PensionFundSeeder
  extend self

  def seed
    json_files.each do |file|
      country_code = File.basename(file, '.json')
      file = Rails.root.to_s
      file += "/spec/fixtures/pension_funds/#{country_code}.json"

      funds = JSON.parse(File.read(file))
      funds.each do |f|
        fund = PensionFund.find_or_initialize_by(fund: f['fund'], email: f['email'])
        fund.name = f['name']
        fund.country_code = country_code.to_s.upcase
        status =  fund.save
        puts fund.errors.inspect unless status
      end
    end
  end

  def json_files
    Dir.glob(Rails.root.to_s + "/spec/fixtures/pension_funds/*.json")
  end
end
