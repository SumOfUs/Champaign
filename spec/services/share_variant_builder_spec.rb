# frozen_string_literal: true

require 'rails_helper'

describe ShareVariantBuilder do
  let(:params) { { title: 'foo', description: 'bar' } }

  let(:sp_variants) { [{ id: 123 }] }

  let!(:page) { create(:page) }

  let(:success_sp_button) do
    double(:button,
           save: true,
           button_template: 'sp_fb_large',
           id: '1',
           share_button_html: '<div />',
           page_url: 'http://example.com/foo',
           variants: { facebook: sp_variants })
  end

  let(:failure_sp_button) do
    double(:button,
           save: false,
           errors: { 'variants' => [['email_body needs {LINK}']] })
  end

  describe '.update_button_url' do
    let(:button) { create(:share_button, :facebook) }
    let(:sp_button) { double(:ShareProgressButton, save: true) }

    before do
      allow(ShareProgress::Button).to receive(:new) { sp_button }
      ShareVariantBuilder.update_button_url('http://example.com', button)
    end

    it 'saves button on ShareProgress' do
      expect(ShareProgress::Button).to have_received(:new)
        .with(id: '2',
              page_url: 'http://example.com',
              button_template: 'sp_fb_large')

      expect(sp_button).to have_received(:save)
    end

    it 'updates button URL' do
      expect(button.reload.url).to eq('http://example.com')
    end
  end

  describe '.create' do
    subject(:create_variant) do
      ShareVariantBuilder.create(
        params: params,
        variant_type: 'facebook',
        page: page,
        url: 'http://example.com/foo'
      )
    end

    describe 'success' do
      before do
        allow(ShareProgress::Button).to receive(:new) { success_sp_button }
      end

      it 'creates a share progress variant' do
        expected_arguments = {
          page_url: 'http://example.com/foo',
          page_title: "#{page.title} [facebook]",
          button_template: 'sp_fb_large'
        }
        expect(ShareProgress::Button).to receive(:new).with(hash_including(expected_arguments)) { success_sp_button }
        create_variant
      end

      it 'creates a variant that is associated with a button' do
        variant = create_variant
        expect(variant.button_id).to_not be(nil)
      end

      it 'persists variant locally' do
        create_variant
        variant = Share::Facebook.first

        expect(variant.title).to eq('foo')
        expect(variant.sp_id).to eq('123')
      end

      it 'persists button locally' do
        create_variant

        button = Share::Button.first
        expect(button.sp_id).to eq('1')
        expect(button.share_button_html).to eq('<div />')
        expect(button.url).to eq 'http://example.com/foo'
      end

      it 'uses URL from previous' do
        variant = create_variant
        expected_url = variant.button.url

        new_variant = ShareVariantBuilder.create(
          params: params,
          variant_type: 'facebook',
          page: page,
          url: 'http://ignored.com'
        )

        expect(new_variant.button.url).to eq(expected_url)
      end
    end

    describe 'failure' do
      before do
        allow(ShareProgress::Button).to receive(:new) { failure_sp_button }
      end

      it 'does not persist variant locally' do
        expect { create_variant }.not_to change { Share::Facebook.count }
        expect(Share::Facebook.first).to eq nil
      end

      it 'does not persist button locally' do
        expect { create_variant }.not_to change { Share::Button.count }
        expect(Share::Button.first).to eq nil
      end

      it 'adds the errors to the variant' do
        variant = create_variant
        expect(variant.errors.size).to eq 1
        expect(variant.errors[:base]).to eq ['email_body needs {LINK}']
      end
    end

    describe 'reporting unexpected error messages' do
      before do
        allow(ShareProgress::Button).to receive(:new) { failure_sp_button }
      end

      it 'reports with a string error' do
        allow(failure_sp_button).to receive(:errors) { 'Something went wrong' }
        variant = create_variant # if it raises an error, it'll fail here
        expect(variant.errors.size).to eq 1
        expect(variant.errors[:base]).to eq ['Something went wrong']
      end

      it 'reports with an array error' do
        allow(failure_sp_button).to receive(:errors) { ['Dude wheres my car?'] }
        variant = create_variant # if it raises an error, it'll fail here
        expect(variant.errors.size).to eq 1
        expect(variant.errors[:base]).to eq ['["Dude wheres my car?"]']
      end

      it 'reports with a singly nested error' do
        allow(failure_sp_button).to receive(:errors) { { 'variants' => ['the body needs {LINK}'] } }
        variant = create_variant # if it raises an error, it'll fail here
        expect(variant.errors.size).to eq 1
        expect(variant.errors[:base]).to eq ['{"variants"=>["the body needs {LINK}"]}']
      end

      it 'reports with an unnested error' do
        allow(failure_sp_button).to receive(:errors) { { 'variants' => 'your body needs {LINK}' } }
        variant = create_variant # if it raises an error, it'll fail here
        expect(variant.errors.size).to eq 1
        expect(variant.errors[:base]).to eq ['{"variants"=>"your body needs {LINK}"}']
      end

      it 'reports with an unknown key' do
        allow(failure_sp_button).to receive(:errors) { { 'some_error' => [['your body wants {LINK}']] } }
        variant = create_variant # if it raises an error, it'll fail here
        expect(variant.errors.size).to eq 1
        expect(variant.errors[:base]).to eq ['your body wants {LINK}']
      end
    end
  end

  describe '.update' do
    let!(:share) { create(:share_facebook, title: 'Foo') }
    let!(:button) { create(:share_button, share_type: 'facebook', page: page, sp_id: 23) }
    let(:params) { { title: 'Bar' } }

    subject(:update_variant) do
      ShareVariantBuilder.update(
        params: params,
        variant_type: 'facebook',
        page: page,
        id: share.id
      )
    end

    describe 'success' do
      before do
        allow(ShareProgress::Button).to receive(:new) { success_sp_button }
      end

      it 'updates variant' do
        expect { update_variant }.to(
          change { share.reload.title }.from('Foo').to('Bar')
        )
      end

      it 'updates variant on share progress' do
        expect(ShareProgress::Button).to receive(:new)
        expect(success_sp_button).to receive(:save)
        update_variant
      end

      it 'does not request to SP API if nothing changed' do
        expect(ShareProgress::Button).to receive(:new)
        expect(success_sp_button).to receive(:save)
        update_variant
        expect(ShareProgress::Button).not_to receive(:new)
        expect(success_sp_button).not_to receive(:save)
        update_variant
      end
    end

    describe 'failure' do
      before do
        allow(ShareProgress::Button).to receive(:new) { failure_sp_button }
      end

      it 'does not update variant locally' do
        expect { update_variant }.not_to change { share.reload.title }
      end

      it 'adds the errors to the variant' do
        variant = update_variant
        expect(variant.errors[:base]).to eq ['email_body needs {LINK}']
      end
    end
  end

  context '.destroy' do
    subject(:destroy_variant) do
      ShareVariantBuilder.destroy(
        params: params,
        variant_type: 'facebook',
        page: page,
        id: share.id
      )
    end

    describe 'success' do
      let!(:button) { create(:share_button, share_type: 'facebook', page: page, sp_id: 24) }
      let!(:share) { create(:share_facebook, title: 'herpaderp', sp_id: 24) }
      let(:params) { { title: 'Bar' } }

      before do
        allow(ShareProgress::Button).to receive(:new) { success_sp_button }
      end

      it 'returns an object with no errors' do
        VCR.use_cassette('shareprogress_destroy_variant_success', match_requests_on: %i[host path]) do
          expect(ShareProgress::Button).to receive(:new)
          result = destroy_variant
          expect(result.errors[:base]).to eq []
        end
      end

      it 'removes the variant from local storage' do
        VCR.use_cassette('shareprogress_destroy_variant_success', match_requests_on: %i[host path]) do
          expect(ShareProgress::Button).to receive(:new)
          expect(Share::Facebook.find(share.id)).to eq(share)
          destroy_variant
          expect { Share::Facebook.find(share.id) }.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe 'failure' do
      let!(:button) { create(:share_button, share_type: 'facebook', page: page, sp_id: nil) }
      let!(:share) { create(:share_facebook, title: 'herpaderp', sp_id: nil) }
      let(:params) { { title: 'Bar' } }

      before do
        allow(ShareProgress::Button).to receive(:new) { success_sp_button }
      end

      it 'returns errors from ShareProgress' do
        VCR.use_cassette('shareprogress_destroy_variant_fail') do
          expect(ShareProgress::Button).to receive(:new)
          result = destroy_variant
          expect(result.errors[:base]).to eq(["{\"id\"=>[\"can't be blank\"]}"])
        end
      end

      it 'does not remove the variant from local storage' do
        VCR.use_cassette('shareprogress_destroy_variant_fail') do
          expect(Share::Facebook.find(share.id)).to eq(share)
          destroy_variant
          expect(Share::Facebook.find(share.id)).to eq(share)
        end
      end
    end
  end
end
