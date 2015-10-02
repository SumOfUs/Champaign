require 'rails_helper'

describe ShareProgressVariantBuilder do
  let(:params) {     {title: 'foo', description: 'bar'} }

  let(:sp_variants)   { [{id: 123}] }

  let(:page){ create(:page) }

  let(:sp_button) do
    double(:button,
           save: true,
           id: '1',
           share_button_html: '<div />',
           variants: {facebook:  sp_variants})
  end

  describe '.create' do
    before do
      allow(ShareProgress::Button).to receive(:new){ sp_button }
    end

    subject(:create_variant) do
      ShareProgressVariantBuilder.create(params, {
        variant_type: 'facebook',
        page: page,
        url: 'http://example.com/foo'
      })
    end

    it 'creates a share progress variant' do
      expected_arguments = {
        page_url: 'http://example.com/foo',
        page_title: "#{page.title} [facebook]",
        button_template: 'sp_fb_large'
      }
      expect(ShareProgress::Button).to receive(:new).with( hash_including(expected_arguments) ){ sp_button }
      create_variant
    end

    it 'persists variant locally' do
      create_variant
      variant = Share::Facebook.first

      expect(variant.title).to eq("foo")
      expect(variant.sp_id).to eq("123")
    end


    it 'persists button locally' do
      create_variant

      button = Share::Button.first
      expect(button.sp_id).to eq("1")
      expect(button.sp_button_html).to eq("<div />")
    end

    it 'needs validation test cases' do
      expect(false).to equal true
    end
  end

  describe '.update' do
    let!(:share) { create(:share_facebook, title: 'Foo') }
    let!(:button){ create(:share_button, sp_type: 'facebook', page: page) }
    let(:params) { {title: 'Bar' } }

    before do
      allow(ShareProgress::Button).to receive(:new){ sp_button }
    end

    subject(:update_variant) do
      ShareProgressVariantBuilder.update(params, {
        variant_type: 'facebook',
        page: page,
        url: 'http://example.com/foo',
        id: share.id
      })
    end

    it 'updates variant' do
      expect{ update_variant }.to(
        change{ share.reload.title }.from('Foo').to('Bar')
      )
    end

    it 'updates variant on share progress' do
      expect(ShareProgress::Button).to receive(:new)
      expect(sp_button).to receive(:save)
      update_variant
    end

    it 'needs validation test cases' do
      expect(false).to equal true
    end
  end
end

