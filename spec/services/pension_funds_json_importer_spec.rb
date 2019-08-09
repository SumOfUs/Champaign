# frozen_string_literal: true

require 'rails_helper'

describe PensionFundsJsonImporter do
  let(:new_json_file) { OpenStruct.new(tempfile: Rails.root.to_s + '/spec/fixtures/new-pension-funds.json') }
  let(:updated_json_file) { OpenStruct.new(tempfile: Rails.root.to_s + '/spec/fixtures/updated-pension-funds.json') }
  let(:au_json_file) { OpenStruct.new(tempfile: Rails.root.to_s + '/spec/fixtures/pension_funds/au.json') }

  context 'import with invalid data' do
    it 'should raise errors' do
      @importer = PensionFundsJsonImporter.new('', '')
      expect(@importer.import).to be_falsey
      expect(@importer.errors).to include('Select a country')
      expect(@importer.errors).to include('Select a JSON file to continue')
    end
  end

  context 'import with valid data' do
    it 'should import data' do
      @importer = PensionFundsJsonImporter.new(new_json_file, 'AU')
      expect(PensionFund.count).to eql 0

      @importer.import
      expect(@importer.errors).to be_empty
      expect(PensionFund.count).to eql 9
    end

    it 'should import file without uuid data' do
      @importer = PensionFundsJsonImporter.new(au_json_file, 'AU')
      expect(PensionFund.count).to eql 0

      @importer.import
      expect(@importer.errors).to be_empty
      expect(PensionFund.count).to eql 42
    end
  end

  context 'update data' do
    it 'should update data via import' do
      @importer = PensionFundsJsonImporter.new(new_json_file, 'AU').import
      expect(PensionFund.count).to eql 9

      @importer = PensionFundsJsonImporter.new(updated_json_file, 'AU').import
      expect(PensionFund.count).to eql 10

      expect(PensionFund.last.email).to match 'watson100@example.com'
    end
  end
end
