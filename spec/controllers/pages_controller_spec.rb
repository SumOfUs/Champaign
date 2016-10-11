# frozen_string_literal: true
require 'rails_helper'

describe PagesController do
  let(:user) { instance_double('User', id: '1') }
  let(:default_language) { instance_double(Language, code: :en) }
  let(:language) { instance_double(Language, code: :fr) }
  let(:page) { instance_double('Page', published?: true, featured?: true, id: '1', liquid_layout: '3', follow_up_liquid_layout: '4', language: default_language) }
  let(:renderer) { instance_double('LiquidRenderer', render: 'my rendered html', personalization_data: { some: 'data' }) }

  include_examples 'session authentication'

  before do
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
      post :create, page: { title: 'Foo Bar' }
    end

    it 'authenticates session' do
      expect(request.env['warden']).to have_received(:authenticate!)
    end

    it 'creates page' do
      expected_params = { title: 'Foo Bar' }

      expect(PageBuilder).to have_received(:create)
        .with(expected_params)
    end

    context 'successfully created' do
      it 'redirects to edit_page' do
        expect(response).to redirect_to(edit_page_path(page.id))
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

    subject { put :update, id: '1', page: { title: 'bar' } }

    it 'authenticates session' do
      subject
      expect(request.env['warden']).to have_received(:authenticate!)
    end

    it 'finds page' do
      expect(Page).to receive(:find).with('1')
      subject
    end

    it 'updates page' do
      expect(page).to receive(:update).with(title: 'bar')
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
    subject { get :show, id: '1' }

    before do
      allow(Page).to            receive(:find) { page }
      allow(page).to            receive(:update)
      allow(LiquidRenderer).to  receive(:new) { renderer }
    end

    include_examples 'show and follow-up'

    it 'renders show template' do
      subject
      expect(response).to render_template :show
    end

    it 'redirects to homepage if page is not found' do
      allow(Page).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
      expect(get(:show, id: '1000000')).to redirect_to(Settings.home_page_url)
    end

    it 'instantiates a LiquidRenderer and calls render' do
      subject
      url_params = { 'id' => '1', 'controller' => 'pages', 'action' => 'show' }
      expect(LiquidRenderer).to have_received(:new).with(page,
                                                         location: {},
                                                         member: nil,
                                                         payment_methods: [],
                                                         layout: page.liquid_layout,
                                                         url_params: url_params)
      expect(renderer).to have_received(:render)
    end

    context 'on pages with localization' do
      let(:french_page)  { instance_double(Page, valid?: true, published?: true, language: language,         id: '42', liquid_layout: '5') }
      let(:english_page) { instance_double(Page, valid?: true, published?: true, language: default_language, id: '66', liquid_layout: '5') }

      context 'with french' do
        subject { french_page }
        before { allow(Page).to receive(:find) { french_page } }

        it 'sets the locality to :fr' do
          get :show, id: '42'
          expect(I18n.locale).to eq :fr
        end

        context 'with default (en)' do
          subject { english_page }
          before { allow(Page).to receive(:find) { english_page } }

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
      allow(Page).to receive(:find) { page }
      allow(page).to receive(:update)
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
                                                           location: {},
                                                           member: anything,
                                                           layout: page.liquid_layout,
                                                           payment_methods: [],
                                                           url_params: anything)
      end

      it 'instantiates a LiquidRenderer and calls render' do
        subject
        url_params = { 'id' => '1', 'controller' => 'pages', 'action' => 'follow_up' }
        url_params.merge!({'member_id' => member.id.to_s}) if member.present?
        expect(LiquidRenderer).to have_received(:new).with(page,
                                                           location: {},
                                                           member: member,
                                                           payment_methods: [],
                                                           layout: page.follow_up_liquid_layout,
                                                           url_params: url_params)
        expect(renderer).to have_received(:render)
      end
    end

    describe 'with no recognized member' do
      subject { get :follow_up, id: '1' }

      let(:url_params) { { 'id' => '1', 'controller' => 'pages', 'action' => 'follow_up' } }
      let(:member) { nil }

      include_examples 'show and follow-up'
      include_examples 'follow-up without redirect'
    end

    describe 'with recognized member' do
      let(:member) { create :member }

      before :each do
        allow(cookies).to receive(:signed).and_return({member_id: member.id})
      end

      describe 'and member_id' do
        subject { get :follow_up, id: '1', member_id: member.id }

        let(:url_params) { { 'member_id' => member.id.to_s, 'id' => '1', 'controller' => 'pages', 'action' => 'follow_up' } }

        include_examples 'show and follow-up'
        include_examples 'follow-up without redirect'
      end

      describe 'and no member_id' do
        subject { get :follow_up, id: '1' }

        it 'redirects to the same route with member id set' do
          subject
          expect(response).to redirect_to follow_up_member_facing_page_path(1, member_id: member.id)
        end

      end
    end

  end
end
