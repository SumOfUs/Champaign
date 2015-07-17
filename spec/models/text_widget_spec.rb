describe TextBodyWidget do

  let(:content) { { text_body_html: "We need to stop rails developers writing tests!" } }
  let(:params) { { page_display_order: 1, content: content } }
  let(:widget) { TextBodyWidget.new(params) }

  subject { widget }
  it { should be_valid }

  describe 'inheritance' do

    it 'should be able to create a widget from the Widget class' do
      w2 = Widget.new(params.merge({type: "TextBodyWidget"}))
      expect(w2).to be_valid
      expect(w2.text_body_html).to eq content[:text_body_html]
    end

  end

  describe 'content' do

    it "should have the initialized values" do
      expect(widget.text_body_html).to eq content[:text_body_html]
    end

    it "should be invalid without a required field" do
      widget.content.delete('text_body_html')
      expect(widget.text_body_html).to be_nil
      expect(widget).not_to be_valid
    end

    it "should coerce string types" do
      widget.text_body_html = 123
      expect(widget).to be_valid
      expect(widget.text_body_html).to eq "123"
    end

    ## Not sure this is necessary. Even if someone
    # should access +content+ directly, the object
    # won't have a getter, so the value would be hidden
    #   widget.content["blah"] = "carrots"
    #   widget.blah // raises undefined method
    it "should be invalid with a non-spec'd key"

    it "should be able to use store_accessor and content[] interchangeably" do
      widget.content['text_body_html'] =  "git on up"
      expect(widget.text_body_html).to eq "git on up"
      widget.text_body_html                        = "git on down"
      expect(widget.content['text_body_html']).to eq "git on down"
    end

  end
end
