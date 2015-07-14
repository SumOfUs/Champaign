describe CampaignPagesController do

  let(:user) { double(:user) }
  let(:campaign_page) { instance_double('CampaignPage', active?: true, featured?: true) }

  context 'logged in' do

    before do
      pending("making collections and redirect work with doubles")
      allow(request.env['warden']).to receive(:authenticate!) { user }
      allow(controller).to receive(:current_user) { user }
    end

    describe 'GET index' do

      before :each do
        allow(CampaignPage).to receive(:where).and_return([campaign_page])
      end

      it 'gets active campaigns' do
        expect(CampaignPage).to receive(:where).with({active: true})
        get :index
      end

      it 'renders index' do
        get :index
        expect(response).to render_template('index')
      end

      it 'assigns @campaign_pages' do
        get :index
        expect(assigns(:campaign_pages)).to eq([campaign_page])
      end
    end

    describe "POST create" do
      let(:fake_params) { { 'name' => 'Foo'} }

      before do
        allow(CampaignPageParameters).to receive_message_chain('new.permit'){ fake_params }
        allow(CampaignPage).to receive(:new) { campaign_page }
        allow(campaign_page).to receive(:save) { true }
        post :create, campaign_page: fake_params
      end

      it 'filters params' do
        expect(CampaignPageParameters).to have_received(:new).with(hash_including({ 'campaign_page' => fake_params}))
      end

      it 'creates new campaign' do
        expect(CampaignPage).to have_received(:new).with(fake_params)
      end

      it 'assigns @campaign' do
        expect(assigns(:campaign_page)).to eq(campaign)
      end

      describe 'with errors' do

        before do
          allow(campaign_page).to receive(:save).and_return(false)
        end

        it 'renders new' do
          expect(response).to render_template(:new)
        end
      end
    end
  end
end


