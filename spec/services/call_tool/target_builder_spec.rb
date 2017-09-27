require 'rails_helper'

describe CallTool::TargetBuilder do
  let(:builder) { CallTool::TargetBuilder }

  context 'without contry params' do
    it 'builds a target with passed attributes' do
      target = builder.run(name: 'John', title: 'Superman', glasses: 'black')
      expect(target).to be_a(CallTool::Target)
      expect(target.name).to eq 'John'
      expect(target.title).to eq 'Superman'
      expect(target.fields[:glasses]).to eq 'black'
    end
  end

  context 'given country_name is passed' do
    it 'assigns the country code if name is valid' do
      target = builder.run(country_name: 'Argentina')
      expect(target.country_code).to eq 'AR'
    end

    it 'normalizes the country name' do
      target = builder.run(country_name: 'argentina')
      expect(target.country_name).to eq 'Argentina'
    end

    it 'nullifies the country_code if name is invalid' do
      target = builder.run(country_name: 'Neverland')
      expect(target.country_code).to be_nil
    end
  end

  context 'given country_code is passed' do
    it 'assigns the country_name if the code is valid' do
      target = builder.run(country_code: 'AR')
      expect(target.country_name).to eq 'Argentina'
    end

    it 'nullifies the country name if the code is invalid' do
      target = builder.run(country_code: 'NLAND')
      expect(target.country_name).to be_nil
    end
  end

  context 'given country is passed' do
    it 'attempts to find a country with a matching country code' do
      target = builder.run(country: 'AR')
      expect(target.country_name).to eq 'Argentina'
    end

    it 'attempts to find a country with a matching country name' do
      target = builder.run(country: 'Argentina')
      expect(target.country_code).to eq 'AR'
    end
  end
end
