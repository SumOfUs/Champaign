describe Tag do

  let(:tag) { create :tag }
  let(:english) { create :language }
  let(:tag_params) { attributes_for :tag }

  subject { tag }

  it { should be_valid }
  it { should respond_to :actionkit_uri }
  it { should respond_to :tag_name }
  it { should respond_to :campaign_pages_tags }
  it { should respond_to :campaign_pages }

  describe 'campaign_pages' do

    before :each do
      3.times do create :campaign_page, language: english end
    end

    describe 'destroy' do

      before :each do
        @tag = create :tag, campaign_page_ids: CampaignPage.last(2).map(&:id)
        expect(@tag.campaign_pages).to match_array(CampaignPage.last(2))
      end

      it 'should not destroy the page' do
        expect{ @tag.destroy }.to change{ CampaignPage.count }.by 0
      end

      it 'should destroy the join table records' do
        expect{ @tag.destroy }.to change{ CampaignPagesTag.count }.by -2
      end

      it 'should destroy the tag' do
        expect{ @tag.destroy }.to change{ Tag.count }.by -1
      end
    end
  end

end
