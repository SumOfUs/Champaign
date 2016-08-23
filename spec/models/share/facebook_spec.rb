# frozen_string_literal: true
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

  describe 'image association' do
    let(:image) { Image.create(content: File.new("spec/fixtures/test-image.gif")) }
    let(:page) { create(:page, images: [image]) }

    it "does not takes a default image" do
      share = create(:share_facebook, page: page)
      expect(share.image).to eq nil
    end

    it "can associate with an image" do
      share = create(:share_facebook, page: page, image: image)
      expect(share.image.content.url).to match('test-image.gif')
    end

    it 'becomes nil when the image is destroyed' do
      share = create(:share_facebook, page: page, image: image)
      expect(share.image.content.url).to match('test-image.gif')
      expect{image.destroy}.not_to raise_error
      expect(share.reload.image).to eq nil
    end
  end
end

