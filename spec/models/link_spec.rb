require 'rails_helper'

describe Link do

  let(:link) { create :link, date: Date.today.to_s, source: "Nature News" }

  subject { link }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :url }
  it { is_expected.to respond_to :source }
  it { is_expected.to respond_to :date }

  describe 'validations' do

    describe 'should be valid' do

      after :each do
        expect(link).to be_valid
      end

      it 'with nil source' do
        link.source = nil
      end

      it 'with nil date' do
        link.source = nil
      end
    end

    describe 'should be invalid' do

      after :each do
        expect(link).to be_invalid
      end

      it 'with nil title' do
        link.title = nil
      end

      it 'with nil url' do
        link.url = nil
      end

      it 'with space string title' do
        link.title = "  "
      end

      it 'with space string url' do
        link.url = "   "
      end
    end
  end
end
