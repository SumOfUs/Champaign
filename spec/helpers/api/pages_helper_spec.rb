# frozen_string_literal: true

require 'rails_helper'

describe Api::PagesHelper do
  describe 'image_url' do
    describe 'returns empty string when page' do
      it 'has no image' do
        page = instance_double(Page, primary_image: nil)
        expect(helper.image_url(page)).to eq ''
      end

      it 'has an image with no content' do
        page = instance_double(Page, primary_image: instance_double(Image, content: nil))
        expect(helper.image_url(page)).to eq ''
      end

      it 'has a content with no medium size photo' do
        page = instance_double(Page, primary_image: instance_double(Image, content: double(url: nil)))
        expect(helper.image_url(page)).to eq ''
      end
    end

    it 'raises NoMethodError if page is not a Page' do
      expect { helper.image_url(nil) }.to raise_error(NoMethodError)
    end

    it 'returns image url when asset_host is a string and content url is a path' do
      allow(ActionController::Base).to receive(:asset_host).and_return('http://www.tragic.com')
      page = instance_double(Page, primary_image: instance_double(Image, content: double(url: '/go-to-hell')))
      expect(helper.image_url(page)).to eq 'http://www.tragic.com/go-to-hell'
    end

    it 'returns image url when asset_host is a string and content url is a path' do
      allow(ActionController::Base).to receive(:asset_host).and_return('')
      page = instance_double(Page, primary_image: instance_double(Image, content: double(url: 'https://s3.aws.amazon.com/go-to-hell')))
      expect(helper.image_url(page)).to eq 'https://s3.aws.amazon.com/go-to-hell'
    end
  end
end
