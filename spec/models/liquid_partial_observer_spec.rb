# frozen_string_literal: true
require 'rails_helper'

describe LiquidPartialObserver do
  let!(:record) { create(:liquid_partial) }

  context 'after save' do
    it 'invalidates cache' do
      expect(LiquidRenderer::Cache).to receive(:invalidate)
      record.save
    end
  end

  context 'after destroy' do
    it 'invalidates cache' do
      expect(LiquidRenderer::Cache).to receive(:invalidate)
      record.destroy
    end
  end
end

