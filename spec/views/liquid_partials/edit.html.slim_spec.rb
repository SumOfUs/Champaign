require 'rails_helper'

RSpec.describe "liquid_partials/edit", type: :view do
  before(:each) do
    @liquid_partial = assign(:liquid_partial, LiquidPartial.create!(
      :title => "MyString",
      :content => "MyText"
    ))
  end

  it "renders the edit liquid_partial form" do
    render

    assert_select "form[action=?][method=?]", liquid_partial_path(@liquid_partial), "post" do

      assert_select "input#liquid_partial_title[name=?]", "liquid_partial[title]"

      assert_select "textarea#liquid_partial_content[name=?]", "liquid_partial[content]"
    end
  end
end
