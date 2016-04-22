require 'rails_helper'

describe PagesHelper do

  let(:page) { build :page, id: 77 }

  describe "#page_nav_item" do
    it "returns li element with link" do
      actual = helper.page_nav_item('foo', '/bar')
      expect(actual).to eq("<li><a href=\"/bar\">foo</a></li>")
    end
  end

  describe "#toggle_switch" do
    it "returns link when active" do
      actual = helper.toggle_switch(true, true, 'foo')
      expect(actual).to eq(
        "<a class=\"btn-primary btn toggle-button btn-default\" data-state=\"true\">foo</a>"
      )
    end

    it "returns link when inactive" do
      actual = helper.toggle_switch(true, false, 'foo')
      expect(actual).to eq(
        "<a class=\" btn toggle-button btn-default\" data-state=\"true\">foo</a>"
      )
    end
  end

  describe '#prefill_link' do
    it 'prefills link for twitter' do
      variant = Share::Twitter.new
      expect(variant.description).to eq nil
      expect(prefill_link(variant).description).to eq '{LINK}'
    end

    it 'prefills link for twitter' do
      variant = Share::Email.new
      expect(variant.body).to eq nil
      expect(prefill_link(variant).body).to eq '{LINK}'
    end

    it 'prefills nothing for facebook' do
      variant = Share::Facebook.new
      expect(prefill_link(variant).attributes).to eq Share::Facebook.new.attributes
    end
  end

  describe "serialize" do

    it 'can serialize with a symbol keys and symbol query' do
      expect(serialize({foo: 'bar'}, :foo)).to eq '"bar"'
    end

    it 'can serialize with a symbol keys and string query' do
      expect(serialize({foo: 'bar'}, 'foo')).to eq '"bar"'
    end

    it 'can serialize with a string keys and symbol query' do
      expect(serialize({'foo' => 'bar'}, :foo)).to eq '"bar"'
    end

    it 'can serialize with a string keys and string query' do
      expect(serialize({'foo' => 'bar'}, 'foo')).to eq '"bar"'
    end

    it 'renders empty object if key is missing' do
      expect(serialize({foo: 'bar'}, :baz)).to eq '{}'
    end

    it 'renders empty object if value is nil' do
      expect(serialize({foo: nil}, :foo)).to eq '{}'
    end

    it 'renders empty string if value is blank' do
      expect(serialize({foo: ' '}, :foo)).to eq "\" \""
    end

    it 'renders empty array if value is empty array' do
      expect(serialize({foo: []}, :foo)).to eq "[]"
    end

    it 'serializes a subhash into appropriate json' do
      expect(serialize({foo: {bar: 'baz', quu: 'ray'}}, :foo)).to eq '{"bar":"baz","quu":"ray"}'
    end
  end

  describe 'share_card' do
    it 'returns {} if no associated share' do
      expect(share_card(page)).to eq({})
    end

    it 'returns content of the only share if just one' do
      share = create :share_facebook, page_id: page.id, title: 'the title', description: 'scripting'
      expect(share_card(page)).to eq({
        title: 'the title',
        description: 'scripting',
        image: nil
      })
    end

    it 'returns content of last share if multiple' do
      share = create :share_facebook, page_id: page.id, title: 'richard', description: 'garfield'
      share = create :share_facebook, page_id: page.id, title: 'the title', description: 'scripting'
      expect(share_card(page)).to eq({
        title: 'the title',
        description: 'scripting',
        image: nil
      })
    end

    it 'returns the url of the image if one exists' do
      allow(Image).to receive(:find_by).and_return(instance_double(Image, content: double(url: 'this/is/a/url')))
      share = create :share_facebook, page_id: page.id, title: 'the title', description: 'scripting'
      expect(share_card(page)).to eq({
        title: 'the title',
        description: 'scripting',
        image: 'this/is/a/url'
      })
    end
  end

  describe 'twitter_meta' do
    it 'has all expected keys' do
      expect(twitter_meta(page).keys).to match_array(%w{
        card domain site creator title description image
      }.map(&:to_sym))
    end

    it 'uses title, description, and image from share_card if present' do
      share_data = {
        title: 'the title',
        description: 'scripting',
        image: 'this/is/a/url'
      }
      expect(twitter_meta(page, share_data)).to include(share_data)
    end

    it 'ignores share_card if empty' do
      expect(twitter_meta(page, {})).to include( title: page.title )
    end

    it "uses only non-blank elements in share_card" do
      share_card = {
        title: '',
        description: 'scripting',
        image: nil
      }
      allow(page).to receive(:primary_image).and_return(instance_double(Image, content: double(url: 'this/is/a/url')))
      expect(twitter_meta(page, share_card)).to include(
        title: page.title,
        description: 'scripting',
        image: 'this/is/a/url'
      )
    end
  end

  describe 'facebook_meta' do
    it 'has all expected keys' do
      expect(facebook_meta(page).keys).to match_array(%w{
        site_name title description url type article image
      }.map(&:to_sym))
    end

    it 'uses title, description, and image from share_card if present' do
      share_data = {
        title: 'the title',
        description: 'scripting',
        image: 'this/is/a/url'
      }
      expect(facebook_meta(page, share_data)).to include(share_data.merge(image: {
        width: '1200',
        height: '630',
        url: 'this/is/a/url'
      }))
    end

    it 'ignores share_card if empty' do
      expect(facebook_meta(page, {})).to include( title: page.title )
    end

    it "uses only non-blank elements in share_card" do
      share_card = {
        title: '',
        description: 'scripting',
        image: nil
      }
      allow(page).to receive(:primary_image).and_return(instance_double(Image, content: double(url: 'this/is/a/url')))
      expect(facebook_meta(page, share_card)).to include(
        title: page.title,
        description: 'scripting',
        image: {
          width: '1200',
          height: '630',
          url: 'this/is/a/url'
        }
      )
    end
  end
end
