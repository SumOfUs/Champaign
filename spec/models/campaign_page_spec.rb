require 'rails_helper'

RSpec.describe CampaignPage do

  let(:english) { create :language }
  let(:text_widget_params_1) { attributes_for :text_widget }
  let(:text_widget_params_2) { attributes_for :text_widget }
  let(:widget_params) { [text_widget_params_1, text_widget_params_2] }
  let(:page_params) { attributes_for :widgetless_page, language: english }
  let(:page) { CampaignPage.new(page_params) }

  subject { page }

  it { should be_valid }
  it { should respond_to :title }
  it { should respond_to :slug }
  it { should respond_to :active }
  it { should respond_to :featured }

  describe :widgets do

    describe :create do
      
      it "should create widgets with good params" do
        old_widget_count = Widget.count
        page = CampaignPage.new(page_params.merge({widgets_attributes: widget_params}))
        page.save
        expect(page.errors.keys).to eq []
        expect(Widget.count).to eq (old_widget_count + 2)
        # expect(PetitionWidget.last.content['petition_text']).to eq petition_widget_params[:petition_text]
      end
    end
  end

  describe :language do
    it 'should be required' do
      page.language = nil
      expect(page).not_to be_valid
    end
  end


end
