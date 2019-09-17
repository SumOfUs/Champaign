# frozen_string_literal: true

require 'rails_helper'

describe Plugins::CallToolsController do
  let(:user) { instance_double('User', id: 1) }
  let(:call_tool) { create :call_tool }

  before do
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
    allow(Plugins).to receive(:find_for).and_return(call_tool)
  end

  describe 'GET export_targets' do
    let(:params) { { params: { id: call_tool.id } } }
    let(:filename) { "calltool-targets-#{call_tool.id}-#{Time.now.to_i}.csv" }
    let(:targets) { call_tool.targets }

    before :each do
      get :export_targets, params
    end

    it 'finds the plugin' do
      expect(assigns(:call_tool).id).to eql call_tool.id
    end

    it 'generate CSV' do
      expect(response.header['Content-Type']).to include 'text/csv'
      expect(response.header['Content-Disposition']).to include filename
    end

    it 'should include the targets content' do
      # Verify all records are exported
      targets.each do |data|
        expect(response.body).to include(data.name)
        expect(response.body).to include(data.phone_number)
      end
    end
  end
end
