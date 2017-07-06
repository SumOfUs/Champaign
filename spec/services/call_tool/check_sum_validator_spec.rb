require 'spec_helper'
require './app/services/call_tool/check_sum_validator'

describe CallTool::CheckSumValidator do
  context 'with valid checksum' do
    it 'returns true' do
      options = {
        number: '1234',
        name: 'Foo Bar',
        checksum: 'f91930',
        secret: 'hello world'
      }

      expect(described_class.validate(options)).to be true
    end
  end

  context 'with invalid checksum' do
    it 'returns true' do
      options = {
        number: '1234',
        name: 'Bar Foo',
        checksum: 'f91930',
        secret: 'hello world'
      }

      expect(described_class.validate(options)).to be false
    end
  end
end
