require 'rails_helper'

shared_examples "view smoke test" do |model_sym|

  model_plural = model_sym.to_s.pluralize.to_sym
  model_class = model_sym.to_s.camelcase.constantize.new

  before do
    view.lookup_context.view_paths.push "app/views/shared"
    view.lookup_context.view_paths.push "app/views/#{model_plural}"
  end

  describe "new" do
    it 'renders without error' do
      assign model_sym, model_class
      expect{ render template: "#{model_plural}/new" }.not_to raise_error
    end
  end

  describe "edit" do
    it 'renders without error' do
      assign model_sym, build(model_sym, id: 1)
      expect{ render template: "#{model_plural}/edit" }.not_to raise_error
    end
  end

  describe "show" do
    it 'renders without error' do
      assign model_sym, build(model_sym, id: 1)
      expect{ render template: "#{model_plural}/show" }.not_to raise_error
    end
  end

  describe "index" do
    it "renders no #{model_plural} without error" do
      assign model_plural, Campaign.none
      expect{ render template: "#{model_plural}/index" }.not_to raise_error
    end

    it "renders multiple #{model_plural} without error" do
      3.times { create model_sym }
      assign model_plural, Campaign.all
      expect{ render template: "#{model_plural}/index" }.not_to raise_error
    end

    it "renders a single campaign without error" do
      create model_sym
      assign model_plural, Campaign.all
      expect{ render template: "#{model_plural}/index" }.not_to raise_error
    end
  end
end