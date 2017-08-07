require 'rails_helper'

describe Target do
  class MTarget < Target
    set_attributes :name, :email
    set_not_filterable_attributes :email
  end

  let(:target) { MTarget.new(name: 'John', fields: { age: '23' }) }

  describe '.attributes' do
    it 'returns the list of set attributes' do
      expect(MTarget.attributes).to eq %i[name email]
    end
  end

  describe '.not_filterable_attributes' do
    it 'returns the list of not filterable attributes' do
      expect(MTarget.not_filterable_attributes).to eq [:email]
    end
  end

  describe '#to_hash' do
    it 'returns a hash with main and custom fields' do
      expect(target.to_hash).to eq(name: 'John', email: nil, fields: { age: '23' })
    end
  end

  describe '#keys' do
    it 'returns the list of fields that are present' do
      expect(target.keys).to match %i[name age]
    end
  end

  describe '#get' do
    it 'returns the value of a main or custom field' do
      expect(target.get('name')).to eq 'John'
      expect(target.get('age')).to eq '23'
    end
  end
end
