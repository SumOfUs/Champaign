require 'rails_helper'
require_relative 'shared_examples'

describe 'campaigns/' do
  include_examples "view smoke test", :campaign
end

describe 'donation_bands/' do
  include_examples "view smoke test", :donation_band, [:edit, :index, :new]
end

describe 'forms/' do
  include_examples "view smoke test", :form, [:index, :new]

  describe "edit" do
    it 'renders without error' do
      assign :form, build(:form, id: 1)
      assign :form_element, FormElement.new
      expect{ render template: "forms/edit" }.not_to raise_error
    end
  end
end

describe 'liquid_layouts/' do
  include_examples "view smoke test", :liquid_layout
end

describe 'liquid_partials/' do
  include_examples "view smoke test", :liquid_partial
end

describe 'pages/' do
  include_examples "view smoke test", :page, [:index, :new, :show]
end
