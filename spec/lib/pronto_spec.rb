# frozen_string_literal: true

require './lib/middleware/pronto'
require 'spec_helper'

describe Pronto::PathMatcher, :focus do
  describe '.match' do
    let(:slug) { '/a/foo-bar' }
    let(:slug_with_trailing_slash) { '/a/foo-bar/' }
    let(:slug_with_query_params) { '/a/foo-bar?akid=123.456.567' }
    let(:slug_with_trailing_slash_and_query_params) { '/a/foo-bar/?akid=123.456.789' }
    let(:slug_with_follow_up) { '/a/foo-bar/follow-up?foo=bar' }
    let(:no_slug) { '/about/staff' }

    context 'returns slug' do
      it 'witout trailing slash' do
        expect(Pronto::PathMatcher.match(slug)).to eq('foo-bar')
      end

      it 'with trailing slash' do
        expect(Pronto::PathMatcher.match(slug_with_trailing_slash)).to eq('foo-bar')
      end

      it 'with query params' do
        expect(Pronto::PathMatcher.match(slug_with_query_params)).to eq('foo-bar')
      end

      it 'with trailing slash and query params' do
        expect(Pronto::PathMatcher.match(slug_with_trailing_slash_and_query_params)).to eq('foo-bar')
      end

      it 'with follow up' do
        expect(Pronto::PathMatcher.match(slug_with_follow_up)).to eq('foo-bar')
      end
    end

    context 'returns nil' do
      it 'when no slug present', :focus do
        expect(Pronto::PathMatcher.match(no_slug)).to be_nil
      end
    end
  end
end
