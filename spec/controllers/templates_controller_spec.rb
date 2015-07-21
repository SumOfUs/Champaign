require 'rails_helper'

describe TemplatesController do
  let(:user) { double(:user) }

  before do
    allow(request.env['warden']).to receive(:authenticate!) { user }
    allow(controller).to receive(:current_user) { user }
  end

  describe 'GET index' do
    it 'renders index' do
      get :index
      expect(response).to render_template('index')
    end
  end
end
