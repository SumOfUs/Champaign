class PensionFundsJsonImporter
  attr_reader :country_code, :file, :errors

  def initialize(file, country_code)
    @file = file
    @country_code = country_code
    @errors = []
  end

  def import
    return false unless valid?

    begin
      funds = JSON.parse(File.read(file.tempfile))
      funds.each do |f|
        record = PensionFund.find_or_initialize_by(uuid: f['uuid'])
        record.fund = f['fund']
        record.name = f['name']
        record.email = f['email']
        record.country_code = country_code
        @errors << record.errors.full_messages.to_sentence unless record.save
      end
    rescue StandardError => e
      @errors << e.message
    end
    @errors.empty?
  end

  def valid?
    @errors << 'Select a country' unless country_code.present?
    @errors << 'Select a JSON file to continue' unless file.present?
    @errors.empty?
  end
end
