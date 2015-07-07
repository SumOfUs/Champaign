describe CampaignPageParameters do

  before :each do
    base_params = { title: "My Sweet Campaign",
                    slug: "my-sweet-campaign",
                    active: true,
                    featured: false,
                    template_id: 1,
                    campaign_id: 2,
                    language_id: 1 }
    @all_params = ActionController::Parameters.new(campaign_page: base_params)
    @params = @all_params[:campaign_page]
  end

  
  describe 'should pass' do

    after :each do
      permitted = CampaignPageParameters.new(@all_params).permit
      expect(permitted).to eq @params.with_indifferent_access
    end

    it 'base params' do
    end

    it 'a list of tag ids as strings' do
      @params[:tags] = ['1', '234', '57']
    end

    it 'a list of tag ids as integers' do
      @params[:tags] = [1, 234, 57]
    end

    it 'an empty tag list' do
      @params[:tags] = []
    end

    it 'an empty widget list' do
      @params[:widgets_attributes] = []
    end

    it 'a widget list with two empty hashes' do
      @params[:widgets_attributes] = [{}, {}]
    end

    it 'a widget list with base params' do
      ps = {id: 1, type: "TextWidget", page_display_order: 1}
      @params[:widgets_attributes] = [ps]
    end

    describe 'widgets content' do

      after :each do
        @params[:widgets_attributes] = [{id: 1, type: "TextWidget", page_display_order: 1, content: @content}]
      end

      it 'with empty content' do
        @content = {}
      end

      it 'with keys from two schemas' do
        @content = {body_html: "Tis a beautiful day", petition_text: "here on the patio."}
      end

      it 'with non-list non-hash type mismatches' do
        @content = {body_html: 1234567, petition_text: false}
      end

      it 'with empty lists and hashes' do
        @content = {checkboxes: [], select_box: {}}
      end

      it 'with lists of all kinds of non-hash non-list types' do
        @content = {checkboxes: ["a", 1, true]}
      end

      it 'with hashes of all kinds of non-hash non-list types' do
        @content = {select_box: {"a" => 1, b: true}}
      end
    end

  end

  describe 'with disallowed' do

    after :each do
      expect{ CampaignPageParameters.new(@all_params).permit }.
          to raise_error(ActionController::UnpermittedParameters)
    end

    it 'should reject a made up key' do
      @params[:neal_enjoys_dragonfruit] = "you bet he does"
    end

    it 'should reject a real key with a hash' do
      @params[:tags] = {pitaya: "Dragonfruit"}
    end

    it 'should reject a real key with a list' do
      @params[:slug] = ["Slimy", "grosss"]
    end

    it 'a widgets_attributes with an unknown key' do
      ps = {id: 1, type: "TextWidget", page_display_order: 1, blerp: 'derp'}
      @params[:widgets_attributes] = [ps]
    end

    describe 'widgets content' do

      after :each do
        @params[:widgets_attributes] = [{id: 1, type: "TextWidget", page_display_order: 1, content: @content}]
      end

      it 'with an known key' do
        @content = {surely_nobody_will_use_this_key: "right?"}
      end

      it 'with a list for a non-list field' do
        @content = {body_html: []}
      end

      it 'with a list for a non-list field' do
        @content = {body_html: {}}
      end

      it 'with a non-list for a list field' do
        @content = {checkboxes: "whale hello there" }
      end

      it 'with a non-hash for a hash field' do
        @content = {select_box: "heyy"}
      end
    end

  end
end
