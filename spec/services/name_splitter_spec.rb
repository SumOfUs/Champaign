require 'spec_helper'

describe NameSplitter do
  it 'splits names in two if there are only two elements' do
    first_name = 'Eric'
    last_name = 'Boersma'
    splitter = NameSplitter.new(full_name: "#{first_name} #{last_name}")
    expect(splitter.first_name).to eq(first_name)
    expect(splitter.last_name).to eq(last_name)
  end

  it 'splits the names in half if there are an even number of names given' do
    first_name = 'John Jacob'
    last_name = 'Jingleheimer Schmidt'
    splitter = NameSplitter.new(full_name: "#{first_name} #{last_name}")
    expect(splitter.first_name).to eq(first_name)
    expect(splitter.last_name).to eq(last_name)
  end
end
