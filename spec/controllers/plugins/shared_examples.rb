# frozen_string_literal: true

shared_examples 'plugins controller' do |plugin_class, plugin_name|
  let(:user) { instance_double('User', id: '1') }

  before do
    allow(request.env['warden']).to receive(:authenticate!) { user }
    allow(controller).to receive(:current_user) { user }
  end

  describe 'PUT #update' do
    let(:plugin) { instance_double(plugin_class) }

    describe 'successful' do
      before do
        allow(plugin_class.base_class).to receive(:find).with('1') { plugin }
        allow(plugin).to receive(:update) { true }
        put :update, params: { id: '1', plugin_name => { title: 'bar' }, format: :js }
      end

      it 'finds the plugin' do
        expect(plugin_class.base_class).to have_received(:find).with('1')
      end

      it 'updates the plugin' do
        ActionController::Parameters.permit_all_parameters = true

        expect(plugin).to have_received(:update)
          .with(ActionController::Parameters.new(title: 'bar'))
      end

      it 'returns 422' do
        expect(response.status).to eq 200
      end

      it 'gives an empty hash' do
        expect(response.body).to eq '{}'
      end
    end

    describe 'failure' do
      before do
        allow(plugin_class.base_class).to receive(:find).with('1') { plugin }
        allow(plugin).to receive(:update) { false }
        allow(plugin).to receive(:errors) { {} }
        put :update, params: { id: '1', plugin_name => { title: 'bar' }, format: :js }
      end

      it 'returns 422' do
        expect(response.status).to eq 422
      end

      it 'gives an error hash' do
        expect(response.body).to eq '{"errors":{},"name":"' + plugin_name.to_s + '"}'
      end
    end
  end
end
