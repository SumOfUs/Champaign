describe CampaignsController do
  let(:user) { double(:user) }
  let(:campaign) { instance_double('Campaign', active?: true) }

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

  describe 'GET new' do
    before do
      allow(Campaign).to receive(:new) { campaign }
      get :new
    end

    it 'instantiates instance of Campaign' do
      expect(Campaign).to have_received(:new)
    end

    it 'assigns campaign' do
      expect(assigns(:campaign)).to eq(campaign)
    end

    it 'renders new' do
      expect(response).to render_template(:new)
    end
  end

  describe 'GET edit' do
    before do
      allow(Campaign).to receive(:find) { campaign }
      get :edit, id: 1
    end

    it 'instantiates instance of Campaign' do
      expect(Campaign).to have_received(:find).with('1')
    end

    it 'assigns campaign' do
      expect(assigns(:campaign)).to eq(campaign)
    end

    it 'renders edit' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'GET show' do
    let(:template) { instance_double('Template') }

    before do
      allow(Campaign).to receive(:find){ campaign }
      allow(ActiveQuery).to receive(:new){ [template] }
    end

    it 'finds campaign' do
      expect(Campaign).to receive(:find).with('1')
      get :show, id: 1
    end

    context "with inactive campaign" do
      let(:campaign) { instance_double('Campaign', active?: false) }

      it 'raises routing error' do
        expect{
          get :show, id: 1
        }.to raise_error(ActionController::RoutingError)
      end
    end

    context "with active campaign" do
      let(:campaign) { instance_double('Campaign', active?: true) }

      before do
        get :show,  id: '1'
      end

      it 'finds active templates' do
        expect(ActiveQuery).to have_received(:new).with(Template)
      end

      it 'assigns campaign' do
        expect(assigns(:campaign)).to eq(campaign)
      end

      it 'assigns templates' do
        expect(assigns(:templates)).to eq([template])
      end
    end
  end

  describe "POST create" do
    let(:fake_params) { { 'name' => 'Foo'} }

    before do
      allow(CampaignParameters).to receive_message_chain('new.permit'){ fake_params }
      allow(Campaign).to receive(:create) { campaign }
      post :create, campaign: fake_params
    end

    it 'filters params' do
      expect(CampaignParameters).to have_received(:new).with(hash_including({ 'campaign' => fake_params}))
    end

    it 'creates new campaign' do
      expect(Campaign).to have_received(:create).with(fake_params)
    end

    it 'assigns campaign' do
      expect(assigns(:campaign)).to eq(campaign)
    end
  end
end

