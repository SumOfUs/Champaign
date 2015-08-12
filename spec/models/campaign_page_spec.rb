describe CampaignPage do

  let(:english) { create :language }
  let(:simple_page) { CampaignPage.new(page_params) }
  let(:existing_page) { create :widgetless_page, language: english, widgets_attributes: widget_params }

  subject { simple_page }

  it { should be_valid }
  it { should respond_to :title }
  it { should respond_to :slug }
  it { should respond_to :active }
  it { should respond_to :featured }
  it { should respond_to :widgets }
  it { should respond_to :tags }
  it { should respond_to :campaign_pages_tags }
  it { should respond_to :campaign }

  describe 'widgets' do

    describe 'create' do
      
      it "should create widgets with good params" do
        old_widget_count = Widget.count
        page = CampaignPage.new(page_params.merge({widgets_attributes: widget_params}))
        expect{ page.save }.to change{ CampaignPage.count }.by 1
        expect(page.errors.keys).to eq []
        expect(Widget.count).to eq (old_widget_count + 3)
        expect(PetitionWidget.last.petition_text).to eq petition_widget_params[:content][:petition_text]
      end

      it "should not create page if one widget has errors" do
        page = CampaignPage.new page_params.merge({widgets_attributes: widget_params.append(bad_widget_params)})
        expect{ page.save }.to change{ CampaignPage.count }.by 0
        expect(page.errors.keys).to include :widgets
      end

      it "should not create any widgets if one widget has errors" do
        page = CampaignPage.new page_params.merge({widgets_attributes: widget_params.append(bad_widget_params)})
        expect{ page.save }.to change{ Widget.count }.by 0
        expect(page.errors.keys).to include :widgets
      end

      it "should not create any widgets if the page has errors" do
        page = CampaignPage.new page_params.merge({widgets_attributes: widget_params, title: nil})
        expect{ page.save }.to change{ Widget.count }.by 0
        expect(page.errors.keys).to eq [:title]
      end
    end

    it 'should compile a simple HTML page with just the title' do
      page = CampaignPage.new title: 'Test Page!'
      page.compile_html
      expect(page.compiled_html).to eq(expected_html)
    end

    describe 'destroy' do
      it 'should destroy the widgets when the page is destroyed' do
        page = existing_page # until existing page is called, it doesn't exist cause let() is lazy
        expect{ page.destroy }.to change{ Widget.count }.by -3
      end

      it 'can destroy associated widgets with updates_attributes' do
        update_params = { widgets_attributes: [{id: existing_page.widgets.first.id, _destroy: "true"}] }
        expect{ existing_page.update_attributes update_params }.to change{ Widget.count }.by -1
      end

      it "won't destroy associated widgets updates_attributes with 'false'" do
        update_params = { widgets_attributes: [{id: existing_page.widgets.first.id, _destroy: "false"}] }
        expect{ existing_page.update_attributes update_params }.to change{ Widget.count }.by 0
      end
    end

    describe 'show' do
      it 'should be able to iterate over the widgets' do
        expect(existing_page.widgets.size).to eq 3
        existing_page.widgets.each do |widget|
          expect(widget.content.keys.size).to be >= 1
        end
      end
    end
  end

  describe 'tags' do

    before :each do
      3.times do create :tag end
    end

    it 'should be a reciprocal many-to-many relationship' do
      page = CampaignPage.create!(page_params.merge({tag_ids: Tag.last(2).map(&:id)}))
      expect(page.tags).to match_array Tag.last(2)
      expect(Tag.last.campaign_pages).to match_array [page]
      expect(Tag.first.campaign_pages).to match_array []
    end

    describe 'create' do

      after :each do
        page = CampaignPage.new page_params
        expect{ page.save! }.to change{ CampaignPagesTag.count }.by 2
        expect(page.tags).to match_array(Tag.last(2))
      end

      it 'should create the many-to-many association with int ids' do
        page_params[:tag_ids] = Tag.last(2).map(&:id).map(&:to_i)
      end

      it 'should create the many-to-many association with string ids' do
        page_params[:tag_ids] = Tag.last(2).map(&:id).map(&:to_s)
      end
    end

    describe 'destroy' do

      before :each do
        @page = create :campaign_page, language: english, tag_ids: Tag.last(2).map(&:id)
      end

      it 'should destroy the page' do
        expect{ @page.destroy }.to change{ CampaignPage.count }.by -1
      end

      it 'should destroy the join table records' do
        expect{ @page.destroy }.to change{ CampaignPagesTag.count }.by -2
      end

      it 'should not destroy the tag' do
        expect{ @page.destroy }.to change{ Tag.count }.by 0
      end
    end

    describe 'update' do

      before :each do
        @page = create :campaign_page, language: english, tag_ids: Tag.last(2).map(&:id)
        @new_ids = Tag.first.id
      end

      it 'should update both sides of the relationship' do
        @page.update! tag_ids: @new_ids
        expect(@page.tags).to eq [Tag.first]
        expect(Tag.first.campaign_pages).to eq [@page]
        expect(Tag.last.campaign_pages).to eq []
      end

      it 'should destroy the old join table records and make a new one' do
        expect{ @page.update! tag_ids: @new_ids }.to change{ CampaignPagesTag.count }.by -1
      end
    end
  end

  describe 'campaigns' do

    before :each do
      3.times do create :campaign end
    end

    describe 'create' do

      after :each do
        page = CampaignPage.new page_params
        expect{ page.save! }.to change{ Campaign.count }.by 0
        expect(page.campaign).to eq Campaign.last
      end

      it 'should create the many-to-many association with int ids' do
        page_params[:campaign_id] = Campaign.last.id.to_i
      end

      it 'should create the many-to-many association with string ids' do
        page_params[:campaign_id] = Campaign.last.id.to_s
      end
    end
  end

  describe 'slug' do

    it 'should auto-fill slug' do
      existing_page.slug = nil
      existing_page.valid?
      expect(existing_page).to be_valid
      expect(existing_page.slug).not_to be_nil
    end

  end

  describe 'language' do
    it 'should be required' do
      simple_page.language = nil
      expect(simple_page).not_to be_valid
    end
  end


end
