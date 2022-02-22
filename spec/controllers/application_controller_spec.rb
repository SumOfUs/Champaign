# frozen_string_literal: true

require 'rails_helper'

describe ApplicationController do
  context 'localization' do
    describe 'localize_from_page_id' do
      let(:english) { create :language, code: 'en' }
      let!(:page) { create :page, language: english }

      before :each do
        allow(controller).to receive(:set_locale)
      end

      it 'does nothing if page_id is blank' do
        controller.send(:localize_from_page_id)
        expect(controller).not_to have_received(:set_locale)
      end

      controller do
        def index
          head :ok
        end
      end

      it 'sets locale with page language code' do
        expect(controller).to receive(:set_locale).with(:en)
        get :index, params: { page_id: page.id }
      end
    end

    describe 'set_locale' do
      it 'sets the locale if it is a known locale' do
        expect do
          controller.send(:set_locale, 'fr')
        end.to change { I18n.locale }.from(:en).to(:fr)
      end

      it 'does nothing when passed an unknown locale' do
        expect do
          controller.send(:set_locale, 'zh')
        end.not_to change { I18n.locale }.from(:en)
      end

      it 'does nothing when passed a blank locale' do
        expect do
          controller.send(:set_locale, nil)
        end.not_to change { I18n.locale }.from(:en)
      end
    end
  end

  describe '#mobile_value' do
    controller do
      def index
        head :ok
      end
    end

    [
      { device: :mobile,  agent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_2 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Mobile/11D257' },
      { device: :desktop, agent: 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36' },
      { device: :tablet,  agent: 'Mozilla/5.0 (iPad; CPU OS 6_1_3 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10B329 Safari/8536.25' },
      { device: :desktop, agent: 'Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.10136é'.dup.force_encoding(Encoding::ASCII_8BIT), note: '(ASCII-8BIT header)' },
      { device: :unknown, agent: '' }
    ].each do |req|
      it "detects headers for #{req[:device]} #{req.fetch(:note, '')}" do
        request.headers['HTTP_USER_AGENT'] = req[:agent]
        get :index

        expect(controller.mobile_value).to eq(action_mobile: req[:device].to_s)
      end
    end
  end

  describe '#authenticate_user!' do
    controller do
      before_action :authenticate_super_admin!

      def index
        head :ok
      end
    end

    let(:user) { build(:user, email: 'test@example.com') }

    before do
      allow(request.env['warden']).to receive(:authenticate!) { user }
      allow(controller).to receive(:current_user) { user }
    end

    it "doesn't raise for whiltelisted users" do
      Settings.admins = 'foo@example.com,test@example.com'

      expect do
        get :index
      end.not_to raise_error
    end
  end
end
