describe ThermometerWidget do

  let(:params) do
    {
      goal: "12345",
      count: "45",
      autoincrement: "0",
      page_display_order: 1
    }
  end
  let(:nested_params) do
    {
      page_display_order: 1,
      content: {
        goal: "657",
        count: "89",
        autoincrement: "1"
      }
    }

  end

  before do
    ThermometerWidget.create!(params)
  end

  subject { Widget.first }

  it { should be_valid }

  describe 'content types' do

    describe 'with setter methods' do
      it 'casts values to the correct type on create' do
        expect(subject.content['count']).to eq(45)
        expect(subject.content['autoincrement']).to be false
      end

      it "casts values to the correct type on update" do
        subject.update_attributes!(autoincrement: '1')
        expect(subject.content['autoincrement']).to be true
      end
    end

    describe 'with content hash' do
      it 'casts values to the correct type on create' do
        widget = ThermometerWidget.create!(nested_params)
        expect(widget.content['count']).to eq(89)
        expect(widget.content['autoincrement']).to be true
      end

      it "casts values to the correct type on update" do
        subject.update_attributes!(nested_params)
        expect(subject.content['autoincrement']).to be true
        expect(subject.content['goal']).to eq 657
      end
    end
  end
end
