require 'rails_helper'

describe LiquidTagFinder do

  describe "plugin_names" do

    after :each do
      actual = LiquidTagFinder.new(@content).plugin_names
      expect(actual).to match_array @expected
    end

    it "finds a plugin in deeply nested nodes (should work but needs spec)"

    it "finds a plugin in a basic variable tag" do
      @content  = "<div>{{ plugins.example.content }}</div>"
      @expected = ['example']
    end

    it "finds a plugin in a for loop tag" do
      @content  = "<div>{% for field in plugins.action.fields %}<p>hey</p>{% endfor %}</div>"
      @expected = ['action']
    end

    it "finds a plugin with underscores, numbers, and capital letters in the name" do
      @content  = "<div>{{ plugins.my_exAMPle_2.content }}</div>"
      @expected = ['my_exAMPle_2']
    end

    it "finds a plugin in a for loop tag" do
      @content  = "<div>{% for field in plugins.action.fields %}<p>hey</p>{% endfor %}</div>"
      @expected = ['action']
    end

    it "finds a plugin referenced twice in the same way" do
      @content  = "<div>{{ plugins.Nd_0.title }}<p>{{ plugins.Nd_0.title }}</p></div>"
      @expected = ['Nd_0']
    end

    it "finds a plugin nested in a ref to the same plugin" do
      @content  = "<div>{% for field in plugins.Nd_0.fields %}<p>{{ plugins.Nd_0.title }}</p>{% endfor %}</div>"
      @expected = ['Nd_0']
    end

    it "finds a plugin nested in a ref to the same plugin" do
      @content  = "<div>{% for field in plugins.Nd_0.fields %}<p>{{ plugins.chill.title }}</p>{% endfor %}</div>"
      @expected = ['Nd_0', 'chill']
    end

    it "finds plugin nested deeply" do
      @content = "{% for field in plugins.Nd_0.fields %}
                    {% if plugins.Nd_0.is_chill %}
                      <h2>{{ plugins.chill.title }}</h2>
                    {% else %}
                      {% unless field == 'derp' %}
                        {{ plugins.Nd_1 }}
                        {{ include 'something' }}
                      {% endunless %}
                    {% endif %}
                  {% endfor %}"
      @expected = ['Nd_0', 'chill', 'Nd_1']
    end
  end



  describe "partial_names" do

    after :each do
      actual = LiquidTagFinder.new(@content).partial_names
      expect(actual).to eq @expected
    end

    it 'identifies a single include tag that uses single quotes' do
      @content  = "<div class='foo'>{% include 'example' %}</div>"
      @expected = ["example"]
    end

    it 'identifies a single include tag that uses double quotes' do
      @content  = '<div class="foo">{% include "example" %}</div>'
      @expected = ["example"]
    end

    it 'identifies a single include tag that passes a parameter' do
      @content  = '<div class="foo">{% include "my-template", color: "#f3a900" %}</div>'
      @expected = ["my-template"]
    end

    it 'identifies two tags without matching a variable' do
      @content = %Q{<section class="wrapper">
                      <div class="foo">
                        {% include "example" %}
                      </div>
                      <h2>{{ title }}</h2>
                      <div class='bar'>
                        {% include 'swell' %}
                      </div>
                    </section>}
      @expected = ["example", "swell"]
    end
  end

end
