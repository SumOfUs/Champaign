describe ThermometerWidget do

  let(:params) do
    {
      goal: "12345",
      count: "45",
      autoincrement: "0",
      page_display_order: 1
    }
  end

  before do
    ThermometerWidget.create!(params)
  end

  subject { Widget.first }

  it { should be_valid }

  describe 'content types' do
    it 'casts values to the correct type on create' do
      expect(subject.content['count']).to eq(45)
      expect(subject.content['autoincrement']).to be false
    end

    it "casts values to the correct type on update" do
      subject.update_attributes!(autoincrement: '1')
      expect(subject.content['autoincrement']).to be true
    end
  end
end
