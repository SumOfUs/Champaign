# frozen_string_literal: true

require 'rails_helper'

describe 'PUT plugins/call_tools/:id', type: :request do
  let(:call_tool) { create(:call_tool) }

  before(:each) { login_as(build(:user), scope: :user) }

  context 'given valid params' do
    let(:params) do
      {
        plugins_call_tool: {
          targets_csv_file: fixture_file_upload(Rails.root.join('spec', 'fixtures', 'call_tool_data.csv'))
        }
      }
    end

    it 'returns successfully' do
      post "/plugins/call_tools/#{call_tool.id}/targets", params: params
      expect(response).to have_http_status(:ok)
    end

    it 'updates the call tool instance' do
      post "/plugins/call_tools/#{call_tool.id}/targets", params: params
      call_tool.reload
      expect(call_tool.targets.any?).to be true
    end
  end

  context 'given targets with accents' do
    let(:params) do
      {
        plugins_call_tool: {
          targets_csv_file: fixture_file_upload(Rails.root.join('spec', 'fixtures', 'call_tool_data_with_accents.csv'))
        }
      }
    end

    it 'returns successfully' do
      post "/plugins/call_tools/#{call_tool.id}/targets", params: params
      expect(response).to have_http_status(:ok)
    end

    it 'updates the call tool instance' do
      post "/plugins/call_tools/#{call_tool.id}/targets", params: params
      call_tool.reload
      expect(call_tool.targets.any?).to be true
    end
  end

  context 'given invalid params' do
    let(:params) do
      {
        plugins_call_tool: {
          targets_csv_file: fixture_file_upload(Rails.root.join('spec', 'fixtures', 'invalid_call_tool_data.csv'))
        }
      }
    end

    it 'returns 422' do
      post "/plugins/call_tools/#{call_tool.id}/targets", params: params
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
