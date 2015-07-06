describe CampaignPagesController do

  let(:english) { create :language }
  let( :admin ) { create :admin }
  let(:petition_widget_params) { attributes_for :petition_widget }
  let(:text_widget_params_1) { attributes_for :text_widget }
  let(:text_widget_params_2) { attributes_for :text_widget }
  let(:widget_params) { [petition_widget_params, text_widget_params_1, text_widget_params_2] }
  let(:page_params) { attributes_for :widgetless_page, language_id: english.id }
  let(:page_widget_params) { page_params.merge({widgets_attributes: widget_params}) }

  # for error cases
  let(:bad_widget_params) { attributes_for :text_widget, content: { body_html: nil } }
  let(:bad_page_params) { attributes_for :widgetless_page, language_id: nil }
  let(:bad_widget_page_params) { page_params.merge({widgets_attributes: bad_widget_params}) }
  let(:widget_bad_page_params) { bad_page_params.merge({widgets_attributes: widget_params}) }

  # let(:existing_page) { p = CampaignPage.new(page_widget_params); p.save!; p }

  describe "logged in as admin" do

    before :each do
      expect(admin).to be_persisted
      allow(controller).to receive(:current_user) { admin }
    end

    describe 'create' do

      describe 'success' do

        after :each do
          expect(response).to redirect_to CampaignPage.last
        end

        it 'should be able to create a page without widgets' do
          expect{ post :create, campaign_page: page_params }.to change{ CampaignPage.count }.by 1
        end

        it 'should be able to create a page with widgets' do
          expect{ post :create, campaign_page: page_widget_params }.to change{ CampaignPage.count }.by 1
        end

        it 'should be able to create widgets with a page' do
          expect{ post :create, campaign_page: page_widget_params }.to change{ Widget.count }.by 3
        end
      end

      describe 'failure' do

        after :each do
          expect(response).to render_template :new
        end

        it 'should not create a page if page errors' do
          expect{ post :create, campaign_page: widget_bad_page_params }.to change{ CampaignPage.count }.by 0
        end

        it 'should not create a page if widget errors' do
          expect{ post :create, campaign_page: widget_bad_page_params }.to change{ CampaignPage.count }.by 0
        end

        it 'should not create widgets if page errors' do
          pending('moving forward')
          expect{ post :create, campaign_page: bad_widget_page_params }.to change{ Widget.count }.by 0
        end

        it 'should not create widgets if widget errors' do
          pending('moving forward')
          expect{ post :create, campaign_page: bad_widget_page_params }.to change{ Widget.count }.by 0
        end
      end
    end
  end
end


