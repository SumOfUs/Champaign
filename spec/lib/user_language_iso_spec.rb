# frozen_string_literal: true

require 'rails_helper'

describe UserLanguageISO do
  let(:language) { build(:language) }

  subject { UserLanguageISO }

  it 'returns hash for english' do
    expect(subject.for(build(:language, :english))).to eq(user_en: 1)
  end

  it 'returns hash for french' do
    expect(subject.for(build(:language, :french))).to eq(user_fr: 1)
  end

  it 'returns hash for german' do
    expect(subject.for(build(:language, :german))).to eq(user_de: 1)
  end

  it 'returns hash for spanish' do
    expect(subject.for(build(:language, :spanish))).to eq(user_es: 1)
  end

  it 'returns nothing for swedish' do
    expect(subject.for(build(:language, code: 'sv'))).to eq({})
  end
end
