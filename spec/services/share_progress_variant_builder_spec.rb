# frozen_string_literal: true

require 'rails_helper'

describe ShareProgressVariantBuilder do
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

    context 'ShareProgress enabled' do
      let(:sp_button) { double(:ShareProgressButton, save: true) }

      before do
        allow(ShareProgress::Button).to receive(:new) { sp_button }
        ShareProgressVariantBuilder.update_button_url('http://example.com/change-url', button)
      end

      it 'saves button on ShareProgress' do
        expect(ShareProgress::Button).to have_received(:new)
          .with(id: '2',
                page_url: 'http://example.com/change-url',
                button_template: 'sp_fb_large')

        expect(sp_button).to have_received(:save)
      end

      it 'updates button URL' do
        expect(button.reload.url).to eq('http://example.com/change-url')
      end
    end

    context 'ShareProgress disabled' do
      before do
        button.uses_share_progress = false
        button.save!
        allow(ShareProgress::Button).to receive(:new)
        ShareProgressVariantBuilder.update_button_url('http://example.com/change-url', button)
      end

      it 'does not call ShareProgress' do
        expect(ShareProgress::Button).not_to have_received(:new)
      end

      it 'updates button URL' do
        expect(button.reload.url).to eq('http://example.com/change-url')
      end
    end
  end

  describe '.create' do
    subject(:create_variant) do
      ShareProgressVariantBuilder.create(
        params: params,
        variant_type: 'facebook',
        page: page,
        url: 'http://example.com/foo'
      )
    end

    shared_examples 'creation success' do
      it 'creates and returns a variant that is associated with a button' do
        variant = create_variant
        persisted_variant = Share::Facebook.first
        expect(variant.id).to equal(persisted_variant.id)
        expect(variant.button_id).to equal(Share::Button.first.id)
      end

      it 'persists variant locally' do
        expect { create_variant }.to change { Share::Facebook.count }.by 1
        variant = Share::Facebook.first

        expect(variant.title).to eq('foo')
        expect(variant.description).to eq('bar')
      end

      it 'persists button locally' do
        expect { create_variant }.to change { Share::Button.count }.by 1
        expect(Share::Button.first.url).to eq 'http://example.com/foo'
      end

      it 'uses URL from previous variant' do
        variant = create_variant
        expected_url = variant.button.url

        new_variant = ShareProgressVariantBuilder.create(
          params: params,
          variant_type: 'facebook',
          page: page,
          url: 'http://ignored.com'
        )

        expect(new_variant.button.url).to eq(expected_url)
      end
    end

    shared_examples 'creation failure' do
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
        expect(variant.errors[error[0]]).to eq [error[1]]
      end
    end

    context 'ShareProgress disabled' do
      before do
        allow(Settings).to receive(:share_progress_api_key).and_return('')
      end

      describe 'success' do
        it 'does not call ShareProgress' do
          allow(ShareProgress::Button).to receive(:new)
          expect(ShareProgress::Button).not_to receive(:new)
          create_variant
        end

        include_examples 'creation success'
      end

      describe 'failure' do
        let(:error) { [:title, "can't be blank"] }

        before do
          params[:title] = nil
        end

        include_examples 'creation failure'
      end
    end

    context 'ShareProgress enabled' do
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

        it 'saves SP data on the button' do
          create_variant

          button = Share::Button.first
          expect(button.sp_id).to eq('1')
          expect(button.sp_button_html).to eq('<div />')
        end

        it 'saves SP data on the variant' do
          create_variant
          variant = Share::Facebook.first
          expect(variant.sp_id).to eq('123')
        end

        include_examples 'creation success'
      end

      describe 'failure' do
        let(:error) { [:base, 'email_body needs {LINK}'] }

        before do
          allow(ShareProgress::Button).to receive(:new) { failure_sp_button }
        end

        include_examples 'creation failure'
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
  end

  describe '.update' do
    let!(:share) { create(:share_facebook, title: 'Foo') }
    let(:params) { { title: 'Bar' } }

    subject(:update_variant) do
      ShareProgressVariantBuilder.update(
        params: params,
        variant_type: 'facebook',
        page: page,
        id: share.id
      )
    end

    shared_examples 'update failure' do
      it 'does not update variant locally' do
        expect { update_variant }.not_to change { share.reload.title }
      end

      it 'adds the errors to the variant' do
        variant = update_variant
        expect(variant.errors[error[0]]).to eq [error[1]]
      end
    end

    context 'ShareProgress disabled' do
      let!(:button) { create(:share_button, sp_type: 'facebook', page: page, sp_id: 23, uses_share_progress: false) }

      describe 'success' do
        it 'updates variant' do
          expect { update_variant }.to(
            change { share.reload.title }.from('Foo').to('Bar')
          )
        end

        it 'does not call ShareProgress' do
          allow(ShareProgress::Button).to receive(:new)
          expect(ShareProgress::Button).not_to receive(:new)
          update_variant
        end
      end

      describe 'failure' do
        let(:error) { [:description, "can't be blank"] }

        before :each do
          params[:description] = nil
        end

        include_examples 'update failure'
      end
    end

    context 'ShareProgress enabled' do
      let!(:button) { create(:share_button, sp_type: 'facebook', page: page, sp_id: 23) }

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
        let(:error) { [:base, 'email_body needs {LINK}'] }

        before do
          allow(ShareProgress::Button).to receive(:new) { failure_sp_button }
        end

        include_examples 'update failure'
      end
    end
  end

  context '.destroy' do
    let!(:button) { create(:share_button, sp_type: 'facebook', page: page, sp_id: 24) }
    let!(:share) { create(:share_facebook, title: 'herpaderp', sp_id: 24) }
    let(:params) { { title: 'Bar' } }

    subject(:destroy_variant) do
      ShareProgressVariantBuilder.destroy(
        params: params,
        variant_type: 'facebook',
        page: page,
        id: share.id
      )
    end

    shared_examples 'destroy success' do
      it 'returns an object with no errors' do
        result = destroy_variant
        expect(result.errors[:base]).to eq []
      end

      it 'removes the variant from local storage' do
        expect(Share::Facebook.find(share.id)).to eq(share)
        expect { destroy_variant }.to change { Share::Facebook.count }.by(-1)
        expect { Share::Facebook.find(share.id) }.to raise_exception(ActiveRecord::RecordNotFound)
      end

      it 'does not remove the button from local storage' do
        expect(Share::Button.find(button.id)).to eq(button)
        expect { destroy_variant }.not_to change { Share::Button.count }
        expect(Share::Button.find(button.id)).to eq(button)
      end
    end

    shared_examples 'destroy failure' do
      it 'does not remove the variant from local storage' do
        expect { destroy_variant }.not_to change { Share::Facebook.all }
      end

      it 'does not remove the button from local storage' do
        expect { destroy_variant }.not_to change { Share::Button.all }
      end
    end

    context 'ShareProgress disabled' do
      before do
        button.uses_share_progress = false
        button.save!
        allow(ShareProgress::Button).to receive(:new)
        allow(ShareProgress::FacebookVariant).to receive(:new)
      end

      describe 'success' do
        it 'does not call ShareProgress' do
          expect(ShareProgress::Button).not_to receive(:new)
          expect(ShareProgress::FacebookVariant).not_to receive(:new)
          destroy_variant
        end

        include_examples 'destroy success'
      end
    end

    context 'ShareProgress enabled' do
      describe 'success' do
        let(:success_sp_variant) do
          double(:facebook, destroy: true)
        end

        before do
          allow(ShareProgress::Button).to receive(:new) { success_sp_button }
          allow(ShareProgress::FacebookVariant).to receive(:new) { success_sp_variant }
        end

        it 'calls ShareProgress' do
          expect(ShareProgress::Button).to receive(:new)
          expect(ShareProgress::FacebookVariant).to receive(:new)
          destroy_variant
        end

        include_examples 'destroy success'
      end

      describe 'failure' do
        let(:failure_sp_variant) do
          double(:facebook, destroy: false, errors: { 'id' => ["can't be blank"] })
        end

        before do
          allow(ShareProgress::Button).to receive(:new) { success_sp_button }
          allow(ShareProgress::FacebookVariant).to receive(:new) { failure_sp_variant }
        end

        it 'returns errors from ShareProgress' do
          expect(ShareProgress::Button).to receive(:new)
          expect(ShareProgress::FacebookVariant).to receive(:new)
          result = destroy_variant
          expect(result.errors[:base]).to eq(["{\"id\"=>[\"can't be blank\"]}"])
        end

        include_examples 'destroy failure'
      end
    end
  end
end
