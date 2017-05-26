# frozen_string_literal: true
require 'rails_helper'

describe ActionKitController do
  before do
    allow(ActionKit::Helper).to receive(:check_petition_name_is_available)
  end

  include_examples 'session authentication',
                   [{ post: [:check_slug, params: { slug: 'foo-bar', format: :json }] }]

  describe 'POST#check_slug' do
    it 'checks if name is available' do
      expect(ActionKit::Helper)
        .to receive(:check_petition_name_is_available)
        .with('foo-bar')

      post :check_slug, params: { slug: 'foo-bar', format: :json }
    end
  end
end
