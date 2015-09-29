require 'rails_helper'

describe ImagesController do
  let(:page)  { instance_double('Page', valid?: true) }
  let(:image) { double('image', content: 'foo') }

  before do
    allow(Page).to receive(:find){ page }
  end

  describe 'POST #create' do
    before do
      allow(page).to receive_message_chain(:images, :create)
    end

    subject { post :create, page_id: '1', image: { content: 'foo' }, format: :js }

    it 'finds page' do
      subject
      expect(Page).to have_received(:find).with('1')
    end

    it 'creates image' do
      expect(page).to receive_message_chain(:images, :create).with(content: 'foo')
      subject
    end
  end

  describe "DELETE #destroy" do
    before do
      allow(image).to receive(:destroy)
      allow(page).to receive_message_chain(:images, :find) { image }
    end

    subject { delete :destroy, page_id: '1', id: '2', format: :json }

    it 'finds page' do
      expect(Page).to receive(:find).with('1')
      subject
    end

    it 'finds image' do
      expect(page).to receive_message_chain(:images, :find).with('2')
      subject
    end

    it 'destroys image' do
      expect(image).to receive(:destroy)
      subject
    end
  end
end

