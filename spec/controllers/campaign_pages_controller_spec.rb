require 'rails_helper'

RSpec.describe CampaignPagesController, type: :controller do

  let(:english) { create :language }
  let( :admin ) { create :admin }
  let(:petition_widget_params) { attributes_for :petition_widget }
  let(:text_widget_params_1) { attributes_for :text_widget }
  let(:text_widget_params_2) { attributes_for :text_widget }
  # let(:bad_widget_params) { attributes_for :text_widget, content: {} }
  let(:widget_params) { [petition_widget_params, text_widget_params_1, text_widget_params_2] }
  let(:page_params) { attributes_for :widgetless_page, language: english }
  let(:page_widget_params) { page_params.merge({widgets_attributes: widget_params}) }
  # let(:simple_page) { CampaignPage.new(page_params) }
  # let(:existing_page) { p = CampaignPage.new(page_widget_params); p.save!; p }

  describe "logged in as admin" do

    before :each do
      expect(admin).to be_persisted
      allow(controller).to receive(:current_user) { admin }
    end

    describe 'create' do

      it 'should be able to create a page without widgets' do
        expect{ post :create, page_params }.to change{ CampaignPage.count }.by 1
        expect(response).to be_successful
      end

      it 'should be able to create a page with widgets' do
        expect{ post :create, page_widget_params }.to change{ CampaignPage.count }.by 1
        expect(response).to be_successful
      end

      it 'should be able to create widgets with a page' do
        expect{ post :create, page_widget_params }.to change{ CampaignPage.count }.by 3
        expect(response).to be_successful
      end
    end
  end
end


