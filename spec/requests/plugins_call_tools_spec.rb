# frozen_string_literal: true
require 'rails_helper'

describe 'PUT plugins/call_tools/:id', type: :request do
  let(:call_tool) { create(:call_tool) }

  before(:each) { login_as(build(:user), scope: :user) }

  context 'given valid params' do
    let(:params) do
      { title: 'New title',
        targets_csv_file: fixture_file_upload(Rails.root.join('spec', 'fixtures', 'call_tool_data.csv')) }
    end

    it 'returns successfully' do
      put "/plugins/call_tools/#{call_tool.id}", plugins_call_tool: params, format: :js
      expect(response).to have_http_status(:ok)
    end

    it 'updates the call tool instance' do
      put "/plugins/call_tools/#{call_tool.id}", plugins_call_tool: params, format: :js
      call_tool.reload
      expect(call_tool.title).to eq 'New title'
      expect(call_tool.targets.any?).to be true
    end
  end

  context 'given invalid params' do
    let(:params) do
      { targets_csv_file: fixture_file_upload(Rails.root.join('spec', 'fixtures', 'invalid_call_tool_data.csv')) }
    end

    it 'returns 422' do
      put "/plugins/call_tools/#{call_tool.id}", plugins_call_tool: params
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns the error messages' do
      put "/plugins/call_tools/#{call_tool.id}", plugins_call_tool: params
      expect(response_json['errors']['targets']).to be_present
    end
  end
end
