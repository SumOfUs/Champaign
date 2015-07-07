describe CampaignPageParameters do

  before :each do
    base_params = { title: "My Sweet Campaign",
                    slug: "my-sweet-campaign",
                    active: true,
                    featured: false,
                    template_id: 1,
                    campaign_id: 2,
                    language_id: 1 }
    @params = ActionController::Parameters.new(campaign_page: base_params)
  end

  describe 'widget_params' do

    describe 'with all allowed' do

      after :each do
        permitted = CampaignPageParameters.new(@params).permit
        expect(permitted).to eq @params[:campaign_page].with_indifferent_access
      end

      it 'should pass base params' do
      end

      it 'should pass a list of tag ids as strings' do
        @params[:tags] = ['1', '234', '57']
      end

      it 'should pass a list of tag ids as integers' do
        @params[:tags] = [1, 234, 57]
      end

      it 'should pass an empty tag list' do
        @params[:tags] = []
      end

      # TODO: actually test that the widget_params part works as expected

    end

    describe 'with disallowed' do

      after :each do
        expect{ CampaignPageParameters.new(@params).permit }.
            to raise_error(ActionController::UnpermittedParameters)
      end

      it 'should reject a made up key' do
        @params[:neal_enjoys_dragonfruit] = "you bet he does"
      end

      it 'should reject a real key with a list' do
        @params[:featured] = ["Pitaya", "Dragonfruit"]
      end

      it 'should reject a real key with a list' do
        @params[:slug] = ["Slimy", "grosss"]
      end

    end

  end
end
