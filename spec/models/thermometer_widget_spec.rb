describe ThermometerWidget do

  let(:content) { {
    goal: 10000,
    count: 500,
    autoincrement: true
  } }
  let(:string_content) { {
    goal: "12345",
    count: "45",
    autoincrement: "0"
  } }
  let(:desired_content) { {
    goal: 12345,
    count: 45,
    autoincrement: false
  } }
  let(:params) { { page_display_order: 1, content: content } }
  let(:widget) { ThermometerWidget.create!(params) }

  subject { widget }
  it { should be_valid }

  describe 'content types' do

    before :each do
      params[:content] = string_content
    end

    it "should be able to cast the values to the correct type on create" do
      expect{ThermometerWidget.create!(params)}.to change{ Widget.count }.by 1
      expect(ThermometerWidget.last.content).to eq desired_content.with_indifferent_access
    end

    it "should be able to cast the values to the correct type on update" do
      w = widget # reference widget so lazy let is called
      expect{widget.update_attributes!(params)}.to change{ Widget.count }.by 0
      expect(widget.reload.content).to eq desired_content.with_indifferent_access
    end
  end
end
