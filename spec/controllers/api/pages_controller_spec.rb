require 'rails_helper'

describe Api::PagesController do
  describe 'POST #duplicate' do
    let(:page) { double }
    let(:dup)  { double(to_json: {foo: :bar}.to_json) }

    before do
      allow(PageCloner).to receive(:clone){ dup }
      allow(Page).to receive(:find){ page }
    end

    let(:params) {{ id: 1 }}

    before do
      post :duplicate, params
    end

    it 'finds page' do
      expect(Page).to have_received(:find).with("1"){ page }
    end

    describe 'PageCloner' do
      it 'is called with page' do
        expect(PageCloner).to have_received(:clone).with(page, nil)
      end

      context 'with title' do
        let(:params) { { id: 1, title: 'Foo Bar'} }

        it 'is called with title' do
          expect(PageCloner).to have_received(:clone).with(page, 'Foo Bar')
        end
      end
    end

    it 'renders json' do
      expect(response.body).to eq("{\"foo\":\"bar\"}")
    end
  end
end
