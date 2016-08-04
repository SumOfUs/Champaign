require 'rails_helper'

describe UrisController do
  let(:uri) { instance_double('Uri', save: true) }
  let(:user) { instance_double('User', id: '1') }

  describe 'logged in' do

    before :each do
      allow(request.env['warden']).to receive(:authenticate!) { user }
    end

    describe "GET #index" do

      let(:uris) { [build(:uri), build(:uri)] }

      before :each do
        allow(Uri).to receive(:all).and_return(uris)
      end

      it "assigns all uris as @uris" do
        get :index
        expect(assigns(:uris)).to eq(uris)
      end
    end

    describe 'POST #create' do
      let(:params) { { domain: "google.com", path: '/giddyup', page_id: '1' } }

      before do
        allow(Uri).to receive(:new) { uri }

        post :create, uri: params
      end

      it 'creates uri' do
        expect(Uri).to have_received(:new).with(params.stringify_keys)
      end

      it 'saves uri' do
        expect(uri).to have_received(:save)
      end

      context "successfully created" do
        it 'renders uri partial' do
          expect(response).to render_template('_uri')
        end
      end
    end

    describe "DELETE #destroy" do
      before do
        allow(Uri).to receive(:find){ uri }
        allow(uri).to receive(:destroy)

        delete :destroy, id: '2', format: :json
      end

      it 'finds uri' do
        expect(Uri).to have_received(:find).with('2')
      end

      it 'destroys uri' do
        expect(uri).to have_received(:destroy)
      end
    end
  end

end
