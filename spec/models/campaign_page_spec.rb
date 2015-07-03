require 'rails_helper'

RSpec.describe CampaignPage do

  let(:english) { create :language }
  let(:petition_widget_params) { attributes_for :petition_widget }
  let(:text_widget_params_1) { attributes_for :text_widget }
  let(:text_widget_params_2) { attributes_for :text_widget }
  let(:bad_widget_params) { attributes_for :text_widget, content: {} }
  let(:widget_params) { [petition_widget_params, text_widget_params_1, text_widget_params_2] }
  let(:page_params) { attributes_for :widgetless_page, language: english }
  let(:simple_page) { CampaignPage.new(page_params) }
  let(:existing_page) { p = CampaignPage.new(page_params.merge({widgets_attributes: widget_params})); p.save!; p }

  subject { simple_page }

  it { should be_valid }
  it { should respond_to :title }
  it { should respond_to :slug }
  it { should respond_to :active }
  it { should respond_to :featured }
  it { should respond_to :widgets }

  describe :widgets do

    describe :create do
      
      it "should create widgets with good params" do
        old_widget_count = Widget.count
        page = CampaignPage.new(page_params.merge({widgets_attributes: widget_params}))
        expect{ page.save }.to change{ CampaignPage.count }.by 1
        expect(page.errors.keys).to eq []
        expect(Widget.count).to eq (old_widget_count + 3)
        expect(PetitionWidget.last.content['petition_text']).to eq petition_widget_params[:content][:petition_text]
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

    describe :destroy do
      it 'should destroy the widgets when the page is destroyed' do
        page = existing_page # until existing page is called, it doesn't exist cause let() is lazy
        expect{ page.destroy }.to change{ Widget.count }.by -3
      end
    end

    describe :show do

      it 'should be able to iterate over the widgets' do
        expect(existing_page.widgets.size).to eq 3
        existing_page.widgets.each do |widget|
          expect(widget.content.keys.size).to be >= 1
        end
      end
    end

  end

  describe :language do
    it 'should be required' do
      simple_page.language = nil
      expect(simple_page).not_to be_valid
    end
  end


end
