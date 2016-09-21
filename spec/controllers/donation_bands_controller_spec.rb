# frozen_string_literal: true
require 'rails_helper'

describe DonationBandsController do
  let(:donation_band) { instance_double('DonationBand', name: 'Test') }

  before do
    allow(DonationBand).to receive(:find) { donation_band }
  end

  include_examples 'session authentication',
                   { get:  [:index],
                     get:  [:new],
                     get:  [:edit, id: 1] }

  describe 'GET index' do
    it 'authenticates session' do
      expect(request.env['warden']).to receive(:authenticate!)
      get :index
    end

    it 'renders index' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'GET new' do
    before do
      allow(DonationBand).to receive(:new) { donation_band }
      get :new
    end

    it 'authenticates session' do
      expect(request.env['warden']).to have_received(:authenticate!)
    end

    it 'instantiates instance of DonationBand' do
      expect(DonationBand).to have_received(:new)
    end

    it 'assigns donation_band' do
      expect(assigns(:donation_band)).to eq(donation_band)
    end

    it 'renders new' do
      expect(response).to render_template(:new)
    end
  end

  describe 'GET edit' do
    before do
      get :edit, id: 1
    end

    it 'authenticates session' do
      expect(request.env['warden']).to have_received(:authenticate!)
    end

    it 'instantiates an instance of DonationBand' do
      expect(DonationBand).to have_received(:find).with('1')
    end

    it 'assigns donation_band' do
      expect(assigns(:donation_band)).to eq(donation_band)
    end

    it 'renders edit' do
      expect(response).to have_rendered('edit')
    end
  end

  describe 'POST create' do
    let(:fake_params) { { name: 'Test name', amounts: '1 2 3 4 5' } }
    let(:converted_params) { { name: 'Test name', amounts: [1, 2, 3, 4, 5] } }

    before do
      allow(DonationBand).to receive(:create) { donation_band }
      post :create, donation_band: fake_params
    end

    it 'authenticates session' do
      expect(request.env['warden']).to have_received(:authenticate!)
    end

    it 'creates a new donation_band' do
      expect(DonationBand).to have_received(:create).with(converted_params)
    end

    it 'responds with notice' do
      expect(flash[:notice]).to eq('Donation Band has been created.')
    end

    it 'assigns donation_band' do
      expect(assigns(:donation_band)).to eq(donation_band)
    end

    it 'redirects to donation_band' do
      expect(response).to redirect_to(donation_bands_path)
    end
  end
end
