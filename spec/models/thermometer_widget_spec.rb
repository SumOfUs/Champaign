describe ThermometerWidget do

  let(:params) { {
    goal: 10000,
    count: 500,
    autoincrement: true,
    page_display_order: 1
  } }

  subject(:widget) { ThermometerWidget.create!(params) }

  it { should be_valid }

  describe 'validation' do
    it 'requires a goal' do
      subject.goal = nil
      expect(subject).to_not be_valid
    end

    it 'requires a count' do
      subject.count = nil
      expect(subject).to_not be_valid
    end
  end
end
