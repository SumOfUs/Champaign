# frozen_string_literal: true

require 'rails_helper'

describe 'PUT plugins/email_tools/:id', type: :request do
  let(:email_tool) { create(:email_tool) }

  before(:each) { login_as(build(:user), scope: :user) }

  context 'given valid params' do
    let(:params) do
      {
        plugins_email_tool: {
          targets_csv_text: "email, name\njohn@gmail.com, John Doe"
        }
      }
    end

    it 'returns successfully' do
      post "/plugins/email_tools/#{email_tool.id}/targets", params: params
      expect(response).to have_http_status(:ok)
    end

    it 'updates the email tool instance' do
      post "/plugins/email_tools/#{email_tool.id}/targets", params: params
      email_tool.reload
      expect(email_tool.targets.any?).to be true
      expect(email_tool.targets.first.name).to eq('John Doe')
    end
  end

  context 'given invalid params' do
    let(:params) do
      {
        plugins_email_tool: {
          targets_csv_text: "email, name\n,\n"
        }
      }
    end

    it 'returns 422' do
      post "/plugins/email_tools/#{email_tool.id}/targets", params: params
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
