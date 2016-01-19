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

  it 'correctly handles single name full names' do
    first_name = 'Cher'
    last_name = ''
    splitter = NameSplitter.new(full_name: "#{first_name}")
    expect(splitter.first_name).to eq(first_name)
    expect(splitter.last_name).to eq(last_name)
  end

  it 'correctly handles names with three provided names' do
    first_name = 'Jennifer'
    last_name = 'Jason Leigh'
    splitter = NameSplitter.new(full_name: "#{first_name} #{last_name}")
    expect(splitter.first_name).to eq(first_name)
    expect(splitter.last_name).to eq(last_name)
  end

  it 'correctly handles names with five provided names' do
    first_name = 'Charles Philip'
    last_name = 'Arthur George Mountbatten-Windsor'
    splitter = NameSplitter.new(full_name: "#{first_name} #{last_name}")
    expect(splitter.first_name).to eq(first_name)
    expect(splitter.last_name).to eq(last_name)
  end

  it 'correctly handles names with six provided names' do
    first_name = 'Seal Henry Olusegun'
    last_name = 'Olumide Adeola Samuel'
    splitter = NameSplitter.new(full_name: "#{first_name} #{last_name}")
    expect(splitter.first_name).to eq(first_name)
    expect(splitter.last_name).to eq(last_name)
  end

  it 'does not group common name prefixes' do
    # This is an explicit recognition of a place where this class doesn't effectively handle an edge case of
    # a name which doesn't follow conventional Anglo naming standards. Hopefully, some day this test can be deleted,
    # but for now it stands as a recognition that the proper treatment of these names is not included in the
    # expected functionality of this class at this time.
    first_name = 'Josefina de los Sagrados'
    last_name = 'Corazones Fernández del Solar'
    splitter = NameSplitter.new(full_name: "#{first_name} #{last_name}")
    expect(splitter.first_name).to eq(first_name)
    expect(splitter.last_name).to eq(last_name)
  end
end
