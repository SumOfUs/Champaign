require 'rails_helper'

describe Share::Facebook do
  describe 'validation' do
    subject { build(:share_facebook) }

    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'description must be present' do
      subject.description = nil
      expect(subject).to_not be_valid
    end

    it 'title must be present' do
      subject.title = nil
      expect(subject).to_not be_valid
    end
  end

  describe 'before_create' do
    let(:image) { Image.create(content: File.new("spec/fixtures/test-image.png")) }
    let(:page) { create(:page, images: [image]) }

    subject { create(:share_facebook, page: page) }

    context 'without image' do
      it "takes page's first image" do
        expect(subject.image.url).to match('test-image.png')
      end
    end
  end
end

