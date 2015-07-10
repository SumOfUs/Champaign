require 'spec_helper'
require './app/config/champaign_config'

describe ChampaignConfig do
  subject { ChampaignConfig }

  before do
    ChampaignConfig.yaml_location = 'spec/fixtures/champaign.yml'
  end

  describe 'yaml file location' do
    after do
      ChampaignConfig.reset!
    end

    it 'can be set' do
      ChampaignConfig.yaml_location = 'foo/bar.yml'
      expect(ChampaignConfig.instance_variable_get(:@location)).to eq('foo/bar.yml')
    end
  end

  it 'has an oauth domain whitelist' do
    expect(ChampaignConfig.oauth_domain_whitelist).to eq(['sumofus.org'])
  end
end
