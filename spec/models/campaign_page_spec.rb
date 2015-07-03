require 'rails_helper'

RSpec.describe Widget, type: :model do

  # TODO real soon get factory girl set up
  let(:english) { Language.new(language_code: 'en', language_name: "English") }
  let(:text_widget_params_1) { { content: { body_html: "Once in a while you can get shown the light"}, type: "TextWidget", page_display_order: 1} }
  let(:text_widget_params_2) { { content: { body_html: "In the strangest of places if you look at it right"}, type: "TextWidget", page_display_order: 2} }
  # let(:petition_widget_params) { { content: { petition_text: "Casey Jones you better / watch your speed"}, type: "PetitionWidget", page_display_order: 3} }
  let(:widget_params) { [text_widget_params_1, text_widget_params_2] }
  let(:page_params) { {title: "My Campaign", slug: "my-campaign", active: true, featured: false, language: english } }
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
