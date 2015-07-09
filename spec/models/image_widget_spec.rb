describe ImageWidget do

  let(:image_file) { File.new(Rails.root.join('spec','fixtures','test-image.png')) }
  # let(:content) { { image_attributes: { content: image_file } } }
  let(:params) { { page_display_order: 1, image_attributes: { content: image_file } } }
  let(:widget) { ImageWidget.new(params) }

  subject { widget }
  it { should be_valid }

  describe 'image' do

    before :each do
      expect(widget.save).to eq true
    end

    it "creates an Image in the db" do
      expect(Image.count).to eq 1
    end

    it "associates the Image with the ImageWidget" do
      expect(Image.last.widget).to eq widget
    end

    it "saves the image file" do
      path = widget.image.content.path
      expect(File).to exist Rails.root.join(path)
    end

    it "destroys the Image when the widget is destroyed" do
      widget.destroy
      expect(Image.count).to eq 0
    end

  end

  it 'is invalid with json content' do
    widget.content = {image: "there are no allowed keys"}
    expect(widget).to be_invalid
  end
end
