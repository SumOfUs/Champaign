require 'rails_helper'

RSpec.describe TextWidget, type: :model do

  let(:content) { { body_html: "We need to stop rails developers writing tests!" } }
  let(:params) { { page_display_order: 1, content: content } }
  let(:widget) { TextWidget.new(params) }

  subject { widget }
  it { should be_valid }

  describe 'inheritance' do

    it 'should be able to create a widget from the Widget class' do
      w2 = Widget.new(params.merge({type: "TextWidget"}))
      expect(w2).to be_valid
      expect(w2.content['body_html']).to eq content[:body_html]
    end

  end

  describe :content do

    it "should have the initialized values" do
      expect(widget.content['body_html']).to eq content[:body_html]
    end

    it "should be invalid without a required field" do
      widget.content.delete('body_html')
      expect(widget.content['body_html']).to be_nil
      expect(widget).not_to be_valid
    end

    it "should enforce string types" do
      widget.content['body_html'] = 123
      expect(widget).not_to be_valid
    end

    it "should be invalid with a non-spec'd key" do
      widget.content['not_a_real_field'] = "heyy"
      expect(widget).not_to be_valid
    end

  end
end
