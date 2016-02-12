require 'rails_helper'

describe PostalValidator do
  let(:basic_us_postal)   { '12345' }
  let(:complex_us_postal) { '12345-1234' }
  let(:valid_uk)          { 'CR0 3RL' }
  let(:valid_de)          { '13187' }
  let(:valid_fr)          { '75008' }
  let(:invalid_postal)    { 'I can\'t believe it\'s not valid' }

  it 'successfully validates valid postal codes when given the country code' do
    expect(PostalValidator.valid?(basic_us_postal, country_code: :US)).to be(true)
    expect(PostalValidator.valid?(complex_us_postal, country_code: :US)).to be(true)
    expect(PostalValidator.valid?(valid_uk, country_code: :UK)).to be(true)
    expect(PostalValidator.valid?(valid_de, country_code: :DE)).to be(true)
    expect(PostalValidator.valid?(valid_fr, country_code: :FR)).to be(true)
  end

  it 'successfully validates valid postal codes when not given the country code' do
    expect(PostalValidator.valid?(basic_us_postal)).to be(true)
    expect(PostalValidator.valid?(complex_us_postal)).to be(true)
    expect(PostalValidator.valid?(valid_uk)).to be(true)
    expect(PostalValidator.valid?(valid_de)).to be(true)
    expect(PostalValidator.valid?(valid_fr)).to be(true)
  end

  it 'successfully identifies invalid postal codes and rejects them when given country codes' do
    expect(PostalValidator.valid?(invalid_postal, country_code: :US)).to be(false)
    expect(PostalValidator.valid?(invalid_postal, country_code: :US)).to be(false)
    expect(PostalValidator.valid?(invalid_postal, country_code: :UK)).to be(false)
    expect(PostalValidator.valid?(invalid_postal, country_code: :DE)).to be(false)
    expect(PostalValidator.valid?(invalid_postal, country_code: :FR)).to be(false)
  end

  it 'successfully identifies invalid postal codes and rejects them when not given a country code' do
    expect(PostalValidator.valid?(invalid_postal)).to be (false)
  end

  it 'successfully identifies invalid postal codes when given the incorrect country code' do
    expect(PostalValidator.valid?(basic_us_postal, country_code: :UK)).to be(false)
    expect(PostalValidator.valid?(complex_us_postal, country_code: :UK)).to be(false)
    expect(PostalValidator.valid?(valid_uk, country_code: :US)).to be(false)
    expect(PostalValidator.valid?(valid_de, country_code: :UK)).to be(false)
    expect(PostalValidator.valid?(valid_fr, country_code: :UK)).to be(false)
  end
end
