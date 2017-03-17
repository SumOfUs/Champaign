# frozen_string_literal: true
require 'rails_helper'
require_relative 'shared_examples'

describe 'renderin smoke tests' do
  describe 'campaigns/' do
    include_examples 'view smoke test', :campaign
  end

  describe 'donation_bands/' do
    include_examples 'view smoke test', :donation_band, [:edit, :index, :new]
  end

  describe 'forms/' do
    include_examples 'view smoke test', :form, [:index, :new]

    describe 'edit' do
      it 'renders without error' do
        assign :form, build(:form, id: 1)
        assign :form_element, FormElement.new
        expect { render template: 'forms/edit' }.not_to raise_error
      end
    end
  end

  describe 'liquid_layouts/' do
    include_examples 'view smoke test', :liquid_layout
  end

  describe 'liquid_partials/' do
    include_examples 'view smoke test', :liquid_partial
  end

  describe 'pages/' do
    before :each do
      allow(view).to receive(:user_signed_in?).and_return(true)
    end

    include_examples 'view smoke test', :page, [:new, :show]

    describe 'edit' do
      it 'renders without error' do
        assign :page, build(:page, id: 1)
        assign :variations, [build(:share_facebook, id: 1, button: build(:share_button, sp_id: 2, sp_type: 'facebook'))]
        expect { render template: 'pages/edit' }.not_to raise_error
      end
    end

    describe 'index' do
      it 'renders without error' do
        3.times { build(:page) }
        assign :pages, Page.all
        assign :search_params, {}
        expect { render template: 'pages/index' }.not_to raise_error
      end
    end
  end
end
