# frozen_string_literal: true

require 'rails_helper'

describe PostalValidator do
  def valid?(postal, country = nil)
    PostalValidator.new(postal, country_code: country).valid?
  end

  context 'given a US country code' do
    it 'validats US specific format' do
      expect(valid?('12345', :US)).to be(true)
      expect(valid?('12345-1234', :US)).to be(true)
      expect(valid?('12345678', :US)).to be(false)
    end
  end

  context 'given generic valid postal codes' do
    it 'successfully validates them' do
      expect(valid?('abCd')).to be(true)
      expect(valid?('1234')).to be(true)
      expect(valid?('abc-123-B')).to be(true)
    end
  end

  it 'validates only accepted characters are present' do
    expect(valid?('_abc')).to be(false)
    expect(valid?('*123')).to be(false)
  end

  it "validates it's no longer than 9 chars" do
    expect(valid?('123456789')).to be(true)
    expect(valid?('123456789a')).to be(false)
  end
end
