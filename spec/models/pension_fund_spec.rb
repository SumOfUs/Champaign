# == Schema Information
#
# Table name: pension_funds
#
#  id           :bigint(8)        not null, primary key
#  active       :boolean          default(TRUE), not null
#  country_code :string           not null
#  email        :string
#  fund         :string           not null
#  name         :string           not null
#  uuid         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_pension_funds_on_country_code  (country_code)
#  index_pension_funds_on_uuid          (uuid) UNIQUE
#

require 'rails_helper'

RSpec.describe PensionFund, type: :model do
  let(:au_json_file) { OpenStruct.new(tempfile: Rails.root.to_s + '/spec/fixtures/pension_funds/au.json') }
  let(:be_json_file) { OpenStruct.new(tempfile: Rails.root.to_s + '/spec/fixtures/pension_funds/be.json') }

  describe 'validations' do
    it { should validate_presence_of(:country_code) }
    it { should validate_presence_of(:fund) }
    it { should validate_presence_of(:name) }

    it 'should accept valid email format' do
      rec = PensionFund.new(email: 'a@example.com')
      rec.valid?
      rec.errors.keys.should_not include(:email)
    end

    it 'should not accept invalid email format' do
      rec = PensionFund.new(email: '@example.com')
      rec.valid?
      rec.errors.keys.should include(:email)
    end
  end

  describe 'callbacks' do
    before do
      @pension_fund = PensionFund.create(FactoryBot.attributes_for(:pension_fund))
    end

    it 'should have set uuid' do
      expect(@pension_fund.uuid).to be_present
    end

    it 'uuid should not change post update' do
      uuid = @pension_fund.uuid
      @pension_fund.update(name: 'Sample')

      expect(@pension_fund.uuid).to eql uuid
    end
  end

  describe 'filter_by_country_code' do
    before do
      PensionFundsJsonImporter.new(au_json_file, 'AU').import
    end

    it 'should list out respective country funds' do
      expect(PensionFund.filter_by_country_code('AU').size).to eql 5
    end
  end
end
