require 'rails_helper'

describe ShareProgressVariantBuilder do
  let(:params) {     {title: 'foo', description: 'bar'} }
  let(:sp_variants)   { [{id: 123}] }
  let(:campaign_page){ create(:campaign_page) }
  let(:sp_button) do
    double(:button, save: true, id: '1', share_button_html: '<div />', variants: {'facebook' => sp_variants})
  end

  describe '#create' do
    subject(:create_variant) do
      ShareProgressVariantBuilder.create(params, {
        variant_type: 'facebook',
        campaign_page: campaign_page,
        url: 'http://example.com/foo'
      })
    end

    it 'creates a variant' do
      expect(ShareProgress::Button).to receive(:new){ sp_button }
      create_variant
    end
  end
end
