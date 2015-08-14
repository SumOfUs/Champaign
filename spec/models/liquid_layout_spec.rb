require 'rails_helper'

describe LiquidLayout do
  
  let(:layout) { create(:liquid_layout) }

  describe "is valid" do

    after :each do
      expect(layout).to be_valid
    end

    it "with factory settings" do
    end

    it "with a reference to a partial that does exist" do
      create :liquid_partial, title: 'existent'
      layout.content = "<div>{% include 'existent' %}</div>"
    end
  end

  describe "is invalid" do

    after :each do
      expect(layout).to be_invalid
    end

    it "with a blank title" do
      layout.title = " "
    end

    it "with a blank content" do
      layout.content = " "
    end

    it "with a reference to a partial that doesn't exist" do
      layout.content = "<div>{% include 'nonexistent' %}</div>"
    end

  end

  describe "partials" do

    it 'identifies a single include tag that uses single quotes' do
      layout.content = "<div class='foo'>{% include 'example' %}</div>"
      expect(layout.partial_names).to eq ["example"]
    end

    it 'identifies a single include tag that uses double quotes' do
      layout.content = '<div class="foo">{% include "example" %}</div>'
      expect(layout.partial_names).to eq ["example"]
    end

    it 'identifies a single include tag that passes a parameter' do
      layout.content = '<div class="foo">{% include "my-template", color: "#f3a900" %}</div>'
      expect(layout.partial_names).to eq ["my-template"]
    end

    it 'identifies two tags without matching a variable' do
      layout.content = %Q{<section class="wrapper">
                            <div class="foo">
                              {% include "example" %}
                            </div>
                            <h2>{{ title }}</h2>
                            <div class='bar'>
                              {% include 'swell' %}
                            </div>
                          </section>}
      expect(layout.partial_names).to eq ["example", "swell"]
    end
  end

end
