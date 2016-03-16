require 'rails_helper'

describe PagesController do

  around(:each) do |spec|
    I18n.locale = I18n.default_locale
    spec.run
    I18n.locale = I18n.default_locale
  end

  let(:user) { instance_double('User', id: '1') }
  let(:default_language) { instance_double(Language, code: :en) }
  let(:language) { instance_double(Language, code: :fr) }
  let(:page) { instance_double('Page', active?: true, featured?: true, id: '1', liquid_layout: '3', follow_up_liquid_layout: '4', language: default_language) }
  let(:renderer) { instance_double('LiquidRenderer', render: 'my rendered html', personalization_data: { some: 'data'}) }

  before do
    allow(request.env['warden']).to receive(:authenticate!) { user }
    allow(controller).to receive(:current_user) { user }
    allow_any_instance_of(ActionController::TestRequest).to receive(:location).and_return({})
  end

  describe 'GET #index' do
    it 'renders index and uses default localization' do
      get :index
      expect(response).to render_template('index')
      expect(I18n.locale).to eq :en
    end
    it 'resets localization if a non-default localization is used' do
      I18n.locale = :fr
      get :index
      expect(I18n.locale).to eq :en
    end
  end

  describe 'POST #create' do
    let(:page) { instance_double(Page, valid?: true, language: default_language, id: 1) }

    before do
      allow(PageBuilder).to receive(:create) { page }
      post :create, { page: { title: "Foo Bar" }}
    end

    it 'creates page' do
      expected_params = { title: "Foo Bar" }

      expect(PageBuilder).to have_received(:create).
        with(expected_params)
    end

    context "successfully created" do
      it 'redirects to edit_page' do
        expect(response).to redirect_to(edit_page_path(page.id))
      end
    end

    context "successfully created" do
      let(:page) { instance_double(Page, valid?: false, language: default_language) }

      it 'redirects to edit_page' do
        expect(response).to render_template :new
      end
    end
  end

  describe 'PUT #update' do
    let(:page) { instance_double(Page, language: default_language) }

    before do
      allow(Page).to receive(:find){ page }
      allow(page).to receive(:update)
      allow(LiquidRenderer).to receive(:new) { }
      allow(QueueManager).to receive(:push)
    end

    subject { put :update, id: '1', page: { title: 'bar' } }

    it 'finds page' do
      expect(Page).to receive(:find).with('1')
      subject
    end

    it 'updates page' do
      expect(page).to receive(:update).with(title: 'bar')
      subject
    end

    context "successfully updates" do
      before do
        allow(page).to receive(:update){ true }
      end

      it 'posts to queue' do
        expect(QueueManager).to receive(:push).with(page, job_type: :update)
        subject
      end
    end

    context "unsuccessfully updates" do
      it 'posts to queue' do
        expect(QueueManager).to_not receive(:push)
        subject
      end
    end

  end

  describe 'GET #show' do
    subject { page }

    before do
      allow(Page).to            receive(:find){ page }
      allow(page).to            receive(:update)
      allow(LiquidRenderer).to  receive(:new){ renderer }
    end

    it 'finds campaign page' do
      get :show, id: '1'
      expect(Page).to have_received(:find).with('1')
    end

    it 'instantiates a LiquidRenderer and calls render' do
      get :show, id: '1'

      expect(LiquidRenderer).to have_received(:new).with(page,
        location: {},
        member: nil,
        layout: page.liquid_layout,
        url_params: {"id"=>"1", "controller"=>"pages", "action"=>"show"}
      )
      expect(renderer).to have_received(:render)
    end

    it 'assigns @data to personalization_data' do
      get :show, id: '1'
      expect(assigns(:data)).to eq(renderer.personalization_data)
    end

    it 'renders show template' do
      get :show, id: '1'
      expect(response).to render_template :show
    end

    it 'assigns campaign' do
      get :show, id: '1'
      expect(assigns(:rendered)).to eq(renderer.render)
    end

    it 'redirects to sumofus.org if user not logged in and page unpublished' do
      allow(controller).to receive(:user_signed_in?) { false }
      allow(page).to receive(:active?){ false }
      expect( get :show, id: '1' ).to redirect_to('//sumofus.org')
    end

    it 'does not redirect to sumofus.org if user not logged in and page published' do
      allow(controller).to receive(:user_signed_in?) { false }
      allow(page).to receive(:active?){ true }
      expect( get :show, id: '1' ).not_to be_redirect
    end

    it 'does not redirect to sumofus.org if user logged in and page unpublished' do
      allow(controller).to receive(:user_signed_in?) { true }
      allow(page).to receive(:active?){ false }
      expect( get :show, id: '1' ).not_to be_redirect
    end

    it 'does not redirect to sumofus.org if user logged in and page published' do
      allow(controller).to receive(:user_signed_in?) { true }
      allow(page).to receive(:active?){ true }
      expect( get :show, id: '1' ).not_to be_redirect
    end

    it 'redirects to sumofus.org if page is not found' do
      allow(Page).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
      expect( get :show, id: '1000000' ).to redirect_to('//sumofus.org')
    end

    context 'on pages with localization' do
      let(:french_page)  { instance_double(Page, valid?: true, active?: true, language: language,         id: '42', liquid_layout: '5') }
      let(:english_page) { instance_double(Page, valid?: true, active?: true, language: default_language, id: '66', liquid_layout: '5') }

      context 'with french' do
        subject { french_page }
        before { allow(Page).to receive(:find){ french_page } }

        it 'sets the locality to :fr' do
          get :show, id: '42'
          expect(I18n.locale).to eq :fr
        end

        context 'with default (en)' do
          subject { english_page }
          before { allow(Page).to receive(:find){ english_page } }

          it 'sets the locality to :en' do
            get :show, id: '66'
            expect(I18n.locale).to eq :en
          end
        end
      end

    end
  end

  describe 'GET #follow-up' do

    before do
      allow(Page).to receive(:find){ page }
      allow(page).to receive(:update)
      allow(LiquidRenderer).to receive(:new){ renderer }
      get :follow_up, id: '1'
    end

    it 'finds campaign page' do
      expect(Page).to have_received(:find).with('1')
    end

    it 'instantiates a LiquidRenderer and calls render' do
      expect(LiquidRenderer).to have_received(:new).with(page,
        location: {},
        member: nil,
        layout: page.follow_up_liquid_layout,
        url_params: {"id"=>"1", "controller"=>"pages", "action"=>"follow_up"}
      )
      expect(renderer).to have_received(:render)
    end

    it 'renders show template' do
      expect(response).to render_template :show
    end

    it 'assigns @data to personalization_data' do
      expect(assigns(:data)).to eq(renderer.personalization_data)
    end

    it 'assigns campaign' do
      expect(assigns(:rendered)).to eq(renderer.render)
    end

    it 'redirects to sumofus.org if user not logged in and page unpublished' do
      allow(controller).to receive(:user_signed_in?) { false }
      allow(page).to receive(:active?){ false }
      expect( get :follow_up, id: '1' ).to redirect_to('//sumofus.org')
    end

    it 'does not redirect to sumofus.org if user not logged in and page published' do
      allow(controller).to receive(:user_signed_in?) { false }
      allow(page).to receive(:active?){ true }
      expect( get :follow_up, id: '1' ).not_to be_redirect
    end

    it 'does not redirect to sumofus.org if user logged in and page unpublished' do
      allow(controller).to receive(:user_signed_in?) { true }
      allow(page).to receive(:active?){ false }
      expect( get :follow_up, id: '1' ).not_to be_redirect
    end

    it 'does not redirect to sumofus.org if user logged in and page published' do
      allow(controller).to receive(:user_signed_in?) { true }
      allow(page).to receive(:active?){ true }
      expect( get :follow_up, id: '1' ).not_to be_redirect
    end

    it 'raises 404 if page is not found' do
      allow(Page).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
      expect{ get :follow_up, id: '1000000' }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

