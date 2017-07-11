# frozen_string_literal: true

require 'rails_helper'

describe ActionKitController do
  before do
    allow(ActionKit::Helper).to receive(:check_petition_name_is_available)
  end

  include_examples 'session authentication',
                   [{ post: [:check_slug, params: { slug: 'foo-bar', format: :json }] }]

  describe 'POST#check_slug' do
    subject { post :check_slug, params: { slug: 'foo-bar', format: :json } }

    it 'checks if name is available on AK' do
      expect(ActionKit::Helper)
        .to receive(:check_petition_name_is_available)
        .with('foo-bar')

      post :check_slug, params: { slug: 'foo-bar', format: :json }
    end

    it 'returns true if there is no matching page on AK or Champaign' do
      allow(ActionKit::Helper).to receive(:check_petition_name_is_available) { true }
      allow(Page).to receive(:where) { [] }

      subject
      expect(response.body).to eq '{"valid":true}'
    end

    it 'returns false if there is a matching page on AK but not Champaign' do
      allow(ActionKit::Helper).to receive(:check_petition_name_is_available) { false }
      allow(Page).to receive(:where) { [] }

      subject
      expect(response.body).to eq '{"valid":false}'
    end

    it 'returns false if there is a matching page on Champaign but not AK' do
      allow(ActionKit::Helper).to receive(:check_petition_name_is_available) { true }
      allow(Page).to receive(:where) { [double(Page)] }

      subject
      expect(response.body).to eq '{"valid":false}'
    end

    it 'returns false if there is a matching page on AK and Champaign' do
      allow(ActionKit::Helper).to receive(:check_petition_name_is_available) { false }
      allow(Page).to receive(:where) { [double(Page)] }

      subject
      expect(response.body).to eq '{"valid":false}'
    end
  end
end
