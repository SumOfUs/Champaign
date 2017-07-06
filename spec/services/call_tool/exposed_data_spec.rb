require 'rails_helper'

describe CallTool::ExposedData do
  let(:custom_target) do
    {
      target_number: '1234',
      target_name: 'Foo Bar',
      checksum: 'f91930'
    }
  end

  context 'without custom target' do
    subject { CallTool::ExposedData.new({ default: {} }, {}, 'hello world') }

    it 'returns data' do
      expect(subject.to_h).to eq(default: {})
    end
  end

  context 'with custom target' do
    subject { CallTool::ExposedData.new({ default: {} }, custom_target, 'hello world') }

    it 'returns data' do
      expected = {
        default: {
          target_number: '1234',
          target_name: 'Foo Bar',
          checksum: 'f91930'
        }
      }

      expect(subject.to_h).to eq(expected)
    end
  end
end
