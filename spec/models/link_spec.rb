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
      it 'with nil source' do
        link.source = nil
        expect(link).to be_valid
      end

      it 'with nil date' do
        link.date = nil
        expect(link).to be_valid
      end

      it 'starting url with www.' do
        link.url = 'www.google.com'
        expect(link).to be_valid
        expect(link.url).to eq '//www.google.com'
      end

      it 'with bare url' do
        link.url = 'google.com'
        expect(link).to be_valid
        expect(link.url).to eq '//google.com'
      end

      it 'with url starting with http://' do
        link.url = 'http://google.com'
        expect(link).to be_valid
        expect(link.url).to eq 'http://google.com'
      end

      it 'with url starting with https://' do
        link.url = 'https://google.com'
        expect(link).to be_valid
        expect(link.url).to eq 'https://google.com'
      end

      it 'with url starting with //' do
        link.url = '//google.com'
        expect(link).to be_valid
        expect(link.url).to eq '//google.com'
      end
    end

    describe 'should be invalid' do
      it 'with nil title' do
        link.title = nil
        expect(link).to be_invalid
      end

      it 'with nil url' do
        link.url = nil
        expect(link).to be_invalid
      end

      it 'with space string title' do
        link.title = "  "
        expect(link).to be_invalid
      end

      it 'with space string url' do
        link.url = "   "
        expect(link).to be_invalid
      end

      it 'with a url with http:// in the middle' do
        link.url = 'google.com/http://google.com'
        expect(link).to be_invalid
        expect(link.url).to eq 'google.com/http://google.com'
      end

      it 'with a url with // in the middle' do
        link.url = 'google.com//sweet'
        expect(link).to be_invalid
        expect(link.url).to eq 'google.com//sweet'
      end
    end
  end

  describe 'associated page' do
    let!(:page) { create(:page, links: [link]) }

    it 'touches page on update' do
      Timecop.freeze do
        old_time = Time.now.utc

        Timecop.travel(1.hour) do
          expect{ link.update(source: 'BBC') }.to change{
            page.reload.updated_at.to_s
          }.from(old_time.to_s).to((old_time + 1.hour).to_s)
        end
      end
    end
  end
end
