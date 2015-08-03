require 'rails_helper'

RSpec.describe "liquid_partials/show", type: :view do
  before(:each) do
    @liquid_partial = assign(:liquid_partial, LiquidPartial.create!(
      :title => "Title",
      :content => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/MyText/)
  end
end
