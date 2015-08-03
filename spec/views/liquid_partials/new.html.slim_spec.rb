require 'rails_helper'

RSpec.describe "liquid_partials/new", type: :view do
  before(:each) do
    assign(:liquid_partial, LiquidPartial.new(
      :title => "MyString",
      :content => "MyText"
    ))
  end

  it "renders new liquid_partial form" do
    render

    assert_select "form[action=?][method=?]", liquid_partials_path, "post" do

      assert_select "input#liquid_partial_title[name=?]", "liquid_partial[title]"

      assert_select "textarea#liquid_partial_content[name=?]", "liquid_partial[content]"
    end
  end
end
