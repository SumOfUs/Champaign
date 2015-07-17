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
      desired = @params.clone
      permitted = CampaignPageParameters.new(@all_params).permit
      expect(permitted).to eq desired.with_indifferent_access
    end

    it 'base params' do
    end

    it 'a list of tag ids as strings' do
      @params[:tag_ids] = ['1', '234', '57']
    end

    it 'a list of tag ids as integers' do
      @params[:tag_ids] = [1, 234, 57]
    end

    it 'an empty tag list' do
      @params[:tag_ids] = []
    end

    it 'an empty widget list' do
      @params[:widgets_attributes] = []
    end

    it 'a widget list with two empty hashes' do
      @params[:widgets_attributes] = [{}, {}]
    end

    it 'a widget list with base params' do
      ps = {id: 1, type: "TextBodyWidget", page_display_order: 1}
      @params[:widgets_attributes] = [ps]
    end

    it 'a widget list with different content in order' do
      first = {id: 1, content: {a: 'b'}}
      second = {id: 2, type: "TextBodyWidget", content: {'c' => {'d' => 'e'}}}
      third = {id: 3}
      @params[:widgets_attributes] = [first, second, third]
    end

    it 'parameters usable by a store_with setter' do
      @params[:widgets_attributes] = [{
                                        goal: "12345",
                                        count: "45",
                                        autoincrement: "0",
                                        page_display_order: 1,
                                        type: "ThermometerWidget"
                                      }]
    end

    it 'setter params for a nested hash' do
      @params[:widgets_attributes] = [{
                                        checkboxes: ['merrily','merrily','merrily'],
                                        select_box: { life_is_but: 'a dream'},
                                        type: "PetitionWidget"
                                      }]
    end

    describe 'widgets content' do

      after :each do
        @params[:widgets_attributes] = [{id: 1, type: "TextBodyWidget", page_display_order: 1, content: @content}]
      end

      it 'with empty content' do
        @content = {}
      end

      it 'with absolutely any key' do
        @content = {thank_goodness_im_not_debugging_strong_params_anymore: "seriously"}
      end

      it 'with deeply nested hashes' do
        @content = {a: {b: {c: 1}, d: 2}}
      end

      it 'with a string value' do
        @content = "don't get high on your own supply"
      end
    end
  end

  describe 'should reformat' do

    it 'a widgets_attributes hash into a list' do
      first = {id: 1, content: {a: 'b'}}
      second = {id: 2, type: "TextBodyWidget", content: {'c' => {'d' => 'e'}}}
      third = {id: 3}

      @params[:widgets_attributes] = {'10234556' => first, b: second, c: third}
      desired = @params.clone
      desired[:widgets_attributes] = [first, second, third]
      permitted = CampaignPageParameters.new(@all_params).permit
      expect(permitted).to eq desired.with_indifferent_access
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
      @params[:tag_ids] = {pitaya: "Dragonfruit"}
    end

    it 'should reject a real key with a list' do
      @params[:slug] = ["Slimy", "grosss"]
    end

    it 'a widgets_attributes with an unknown key' do
      ps = {id: 1, type: "TextBodyWidget", page_display_order: 1, blerp: 'derp'}
      @params[:widgets_attributes] = [ps]
    end

  end
end
