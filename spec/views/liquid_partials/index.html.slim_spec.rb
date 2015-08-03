require 'rails_helper'

RSpec.describe "liquid_partials/index", type: :view do
  before(:each) do
    assign(:liquid_partials, [
      LiquidPartial.create!(
        :title => "Title",
        :content => "MyText"
      ),
      LiquidPartial.create!(
        :title => "Title",
        :content => "MyText"
      )
    ])
  end

  it "renders a list of liquid_partials" do
    render
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
