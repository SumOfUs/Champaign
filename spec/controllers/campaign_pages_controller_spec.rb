describe CampaignPagesController do

  let(:user) { instance_double('User') }
  let(:campaign_page) { instance_double('CampaignPage', active?: true, featured?: true) }

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

  context 'logged in' do
    before do
      pending("making collections and redirect work with doubles")
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

  describe 'POST sign', :sqs do

    before do
      # send stuff to the correct (fake) address
      ChampaignQueue.client.config.endpoint = $fake_sqs.uri
      # Queue name MUST correspond to the queue name of your AWS SQS queue!
      ChampaignQueue.client.create_queue(queue_name: 'post_test')
    end

    let(:params) { build(:petition_signature_params) }
    let(:browser) { Browser.new }
    let(:expected_object) {
      (params[:signature].clone).merge({
                                           user_agent: browser.user_agent,
                                           browser_detected: browser.known?,
                                           mobile: browser.mobile?,
                                           tablet: browser.tablet?,
                                           platform: browser.platform
                                       })
    }
    it 'posts the signature in the parameters to the AWS SQS' do
      ChampaignQueue::SqsPusher.push( AkUserParams.create(params, browser) )
      results = ChampaignQueue::SqsPoller.poll
      expect(results.messages.first.body).to eq(expected_object.to_json)
    end
  end
end


