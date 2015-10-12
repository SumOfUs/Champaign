require 'rails_helper'

describe PageUpdater do

  let(:page) { create :page }
  subject{ PageUpdater.new(page) }

  it { is_expected.to respond_to :update }
  it { is_expected.to respond_to :errors }
  it { is_expected.to respond_to :refresh? }

  it 'finds plugin params' do
    params = {plugins_action: {a: '1', b: '2'}, page: {e: 'f'}, plugins_thermometer: {c: 'd'}}
    expect(PageUpdater.new(page, params).send(:all_plugin_params)).to eq({plugins_action: {a: '1', b: '2'}, plugins_thermometer: {c: 'd'}})
  end

  describe 'update' do

  end
end
