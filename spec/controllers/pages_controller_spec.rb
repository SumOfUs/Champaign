# frozen_string_literal: true

require 'rails_helper'

describe PagesController do
  let(:user) { instance_double('User', id: '1') }
  let(:default_language) { instance_double(Language, code: :en) }
  let(:language) { instance_double(Language, code: :fr) }
  let!(:follow_up_layout) { create :liquid_layout, title: 'Follow up layout' }
  let!(:liquid_layout)    { create :liquid_layout, title: 'Liquid layout', default_follow_up_layout: follow_up_layout }
  let(:page) { instance_double('Page', published?: true, featured?: true, pronto: false, to_param: 'foo', id: '1', liquid_layout: '3', follow_up_liquid_layout: '4', language: default_language) }
  let(:page_params) { attributes_for :page, liquid_layout_id: liquid_layout.id }
  let(:renderer) do
    instance_double(
      'LiquidRenderer',
      render: 'my rendered html',
      render_follow_up: 'my rendered html',
      personalization_data: { some: 'data' }
    )
  end

  include_examples 'session authentication'

  before do
    ActionController::Parameters.permit_all_parameters = true
    allow(request.env['warden']).to receive(:authenticate!) { user }
    allow(controller).to receive(:current_user) { user }
    allow_any_instance_of(ActionController::TestRequest).to receive(:location).and_return({})
    Settings.home_page_url = 'http://example.com'
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
      post :create, params: { page: { title: 'Foo Bar' } }
    end

    it 'authenticates session' do
      expect(request.env['warden']).to have_received(:authenticate!)
    end

    it 'creates page' do
      expected_params = { title: 'Foo Bar' }

      expect(PageBuilder).to have_received(:create)
        .with(ActionController::Parameters.new(expected_params))
    end

    context 'successfully created' do
      it 'redirects to edit_page' do
        expect(response).to redirect_to(edit_page_path(page))
      end
    end

    context 'successfully created' do
      let(:page) { instance_double(Page, valid?: false, language: default_language) }

      it 'redirects to edit_page' do
        expect(response).to render_template :new
      end
    end
  end

  describe 'PUT #update' do
    let(:page) { instance_double(Page, language: default_language) }

    before do
      allow(Page).to receive(:find) { page }
      allow(page).to receive(:update)
      allow(LiquidRenderer).to receive(:new) {}
      allow(QueueManager).to receive(:push)
    end

    subject { put :update, params: { id: '1', page: { title: 'bar' } } }

    it 'authenticates session' do
      subject
      expect(request.env['warden']).to have_received(:authenticate!)
    end

    it 'finds page' do
      expect(Page).to receive(:find).with('1')
      subject
    end

    it 'updates page' do
      expect(page).to receive(:update).with(
        ActionController::Parameters.new(title: 'bar')
      )
      subject
    end

    context 'successfully updates' do
      before do
        allow(page).to receive(:update) { true }
      end

      it 'posts to queue' do
        expect(QueueManager).to receive(:push).with(page, job_type: :update)
        subject
      end
    end

    context 'unsuccessfully updates' do
      it 'posts to queue' do
        expect(QueueManager).to_not receive(:push)
        subject
      end
    end
  end

  shared_examples 'show and follow-up' do
    it 'finds campaign page' do
      subject
      expect(Page).to have_received(:find).with('1')
    end

    it 'assigns @data to personalization_data' do
      subject
      expect(assigns(:data)).to eq(renderer.personalization_data)
    end

    it 'assigns campaign' do
      subject
      expect(assigns(:rendered)).to eq(renderer.render)
    end

    it 'redirects to homepage if user not logged in and page unpublished' do
      allow(controller).to receive(:user_signed_in?) { false }
      allow(page).to receive(:published?) { false }
      expect(subject).to redirect_to(Settings.home_page_url)
    end

    it 'does not redirect to homepage if user not logged in and page published' do
      allow(controller).to receive(:user_signed_in?) { false }
      allow(page).to receive(:published?) { true }
      allow(page).to receive(:donation_page?) { false }
      expect(subject).not_to be_redirect
    end

    it 'does not redirect to homepage if user logged in and page unpublished' do
      allow(controller).to receive(:user_signed_in?) { true }
      allow(page).to receive(:published?) { false }
      expect(subject).not_to be_redirect
    end

    it 'does not redirect to homepage if user logged in and page published' do
      allow(controller).to receive(:user_signed_in?) { true }
      allow(page).to receive(:published?) { true }
      expect(subject).not_to be_redirect
    end
  end

  describe 'GET #show' do
    subject { get :show, params: { id: '1' } }

    before do
      allow(Page).to            receive(:find) { page }
      allow(page).to            receive(:update)
      allow(page).to            receive(:language_code).and_return('en')
      allow(page).to receive(:donation_page?) { false }
      allow(LiquidRenderer).to receive(:new) { renderer }
    end

    include_examples 'show and follow-up'

    it 'finds page by un-altered slug' do
      expect(Page).to receive(:find).with('foo-BaR')
      get :show, params: { id: 'foo-BaR' }
    end

    it 'finds page with downcased version of slug' do
      expect(Page).to receive(:find).with('foo-BaR').and_raise(ActiveRecord::RecordNotFound)
      expect(Page).to receive(:find).with('foo-bar').and_return(page)
      get :show, params: { id: 'foo-BaR' }
    end

    it 'renders show template' do
      subject
      expect(response).to render_template :show
    end

    it 'redirects to homepage if page is not found' do
      allow(Page).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
      expect(get(:show, params: { id: '1000000' })).to redirect_to(Settings.home_page_url)
    end

    it 'instantiates a LiquidRenderer and calls render' do
      subject
      url_params = { 'id' => '1', 'controller' => 'pages', 'action' => 'show' }
      expect(LiquidRenderer).to have_received(:new).with(page,
                                                         id_mismatch: false,
                                                         location: {},
                                                         member: nil,
                                                         payment_methods: [],
                                                         url_params: url_params)
      expect(renderer).to have_received(:render)
    end

    context 'on pages with localization' do
      let(:french_page) do
        instance_double(Page, valid?: true, pronto: false, published?: true, language_code: language.code, id: '42', liquid_layout: '5')
      end
      let(:english_page) do
        instance_double(Page, valid?: true, pronto: false, published?: true, language_code: default_language.code, id: '66', liquid_layout: '5')
      end

      context 'with french' do
        subject { french_page }
        before { allow(Page).to receive(:find) { french_page } }

        it 'sets the locality to :fr' do
          allow(french_page).to receive(:donation_page?) { false }
          get :show, params: { id: '42' }
          expect(I18n.locale).to eq :fr
        end

        context 'with default (en)' do
          subject { english_page }
          before { allow(Page).to receive(:find) { english_page } }

          it 'sets the locality to :en' do
            allow(english_page).to receive(:donation_page?) { false }
            get :show, params: { id: '66' }
            expect(I18n.locale).to eq :en
          end
        end
      end
    end
  end

  describe 'GET #follow-up' do
    before do
      allow(Page).to receive(:find) { page }
      allow(page).to receive(:update)
      allow(page).to receive(:language_code).and_return('en')
      allow(LiquidRenderer).to receive(:new) { renderer }
    end

    shared_examples 'follow-up without redirect' do
      it 'renders follow_up template' do
        subject
        expect(response).to render_template :follow_up
      end

      it 'raises 404 if page is not found' do
        allow(Page).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'uses main liquid layout if no follow up set' do
        allow(page).to receive(:follow_up_liquid_layout).and_return(nil)
        subject
        expect(LiquidRenderer).to have_received(:new).with(page,
                                                           id_mismatch: anything,
                                                           location: {},
                                                           member: anything,
                                                           payment_methods: [],
                                                           url_params: anything)
      end

      it 'instantiates a LiquidRenderer and calls render' do
        subject
        url_params = { 'id' => '1', 'controller' => 'pages', 'action' => 'follow_up' }
        url_params['member_id'] = member.id.to_s if member.present?
        expect(LiquidRenderer).to have_received(:new).with(page,
                                                           id_mismatch: anything,
                                                           location: {},
                                                           member: member,
                                                           payment_methods: [],
                                                           url_params: url_params)
        expect(renderer).to have_received(:render_follow_up)
      end
    end

    describe 'with no recognized member' do
      subject { get :follow_up, params: { id: '1' } }

      let(:url_params) { { 'id' => '1', 'controller' => 'pages', 'action' => 'follow_up' } }
      let(:member) { nil }

      include_examples 'show and follow-up'
      include_examples 'follow-up without redirect'
    end

    describe 'with recognized member' do
      let(:member) { create :member }

      before :each do
        cookies.signed[:member_id] = member.id
        allow(controller).to receive(:cookies).and_return(cookies)
      end

      describe 'and member_id' do
        subject { get :follow_up, params: { id: '1', member_id: member.id } }

        let(:url_params) { { 'member_id' => member.id.to_s, 'id' => '1', 'controller' => 'pages', 'action' => 'follow_up' } }

        include_examples 'show and follow-up'
        include_examples 'follow-up without redirect'
      end

      describe 'and no member_id' do
        subject { get :follow_up, params: { id: '1' } }

        it 'redirects to the same route with member id set' do
          subject
          expect(response).to redirect_to follow_up_member_facing_page_path(page, member_id: member.id)
        end
      end
    end
  end
end
