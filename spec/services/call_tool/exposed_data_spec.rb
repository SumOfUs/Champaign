require 'rails_helper'

describe CallTool::ExposedData do
  describe 'to_h' do
    let(:url_params) do
      {
        source: 'fwd',
        akid: '1234.5678.4567',
        target_phone_number: '+1 213-555-6789',
        target_phone_extension: '5698',
        target_name: 'Courtney Love',
        target_title: 'High Priestess'
      }
    end
    let(:plugin_instance_data) do
      {
        page_id: 96,
        locale: 'en',
        active: true,
        restricted_country_code: nil,
        targets: []
      }
    end
    let(:plugin_data) { { default: plugin_instance_data } }
    let(:expected_keys) do
      %i[target_phone_number target_phone_extension target_name target_title]
    end

    subject { CallTool::ExposedData.new(plugin_data, url_params).to_h }

    it 'passes the phone number and checksum to the validator' do
      allow(CallTool::ChecksumValidator).to receive(:validate)
      expect(CallTool::ChecksumValidator).to receive(:validate).with(
        url_params[:target_phone_number], url_params[:checksum]
      )
      subject
    end

    it 'returns just the original params when checksum is invalid' do
      allow(CallTool::ChecksumValidator).to receive(:validate).and_return(false)
      expect(subject).to eq plugin_data
    end

    it 'adds all/only the relevant parameters when checksum is valid' do
      allow(CallTool::ChecksumValidator).to receive(:validate).and_return(true)
      expect(subject).to eq(default: plugin_data[:default].merge(url_params.slice(*expected_keys)))
    end

    it 'adds the relevant parameters when checksum is valid and multiple plugins' do
      allow(CallTool::ChecksumValidator).to receive(:validate).and_return(true)
      plugin_data[:other] = plugin_instance_data
      output = plugin_data[:default].merge(url_params.slice(*expected_keys))
      expect(subject).to eq(default: output,
                            other: output)
    end
  end
end
