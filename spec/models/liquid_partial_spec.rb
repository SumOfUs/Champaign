require 'rails_helper'

describe LiquidPartial do
  
  let(:partial) { create(:liquid_partial) }

  it "is valid" do
    expect(partial).to be_valid
  end

  describe "is invalid" do

    after :each do
      expect(partial).to be_invalid
    end

    it "with a blank title" do
      partial.title = " "
    end

    it "with a blank content" do
      partial.content = " "
    end
  end

  describe "plugin_names" do

    it "finds a plugin in deeply nested nodes (should work but needs spec)"

    it "finds a plugin in a basic variable tag" do
      partial.content = "<div>{{ plugins.example.content }}</div>"
      expect(partial.plugin_names).to eq ['example']
    end

    it "finds a plugin in a for loop tag" do
      partial.content = "<div>{% for field in plugins.action.fields %}<p>hey</p>{% endfor %}</div>"
      expect(partial.plugin_names).to eq ['action']
    end

    it "finds a plugin with underscores, numbers, and capital letters in the name" do
      partial.content = "<div>{{ plugins.my_exAMPle_2.content }}</div>"
      expect(partial.plugin_names).to eq ['my_exAMPle_2']
    end

    it "finds a plugin in a for loop tag" do
      partial.content = "<div>{% for field in plugins.action.fields %}<p>hey</p>{% endfor %}</div>"
      expect(partial.plugin_names).to eq ['action']
    end

    it "finds a plugin referenced twice in the same way" do
      partial.content = "<div>{{ plugins.Nd_0.title }}<p>{{ plugins.Nd_0.title }}</p></div>"
      expect(partial.plugin_names).to eq ['Nd_0']
    end

    it "finds a plugin nested in a ref to the same plugin" do
      partial.content = "<div>{% for field in plugins.Nd_0.fields %}<p>{{ plugins.Nd_0.title }}</p>{% endfor %}</div>"
      expect(partial.plugin_names).to eq ['Nd_0']
    end

    it "finds a plugin nested in a ref to the same plugin" do
      partial.content = "<div>{% for field in plugins.Nd_0.fields %}<p>{{ plugins.chill.title }}</p>{% endfor %}</div>"
      expect(partial.plugin_names).to eq ['Nd_0', 'chill']
    end

    it "finds plugin nested deeply" do
      partial.content = "{% for field in plugins.Nd_0.fields %}
                          {% if plugins.Nd_0.is_chill %}
                            <h2>{{ plugins.chill.title }}</h2>
                          {% else %}
                            {% unless field == 'derp' %}
                              {{ plugins.Nd_1 }}
                              {{ include 'something' }}
                            {% endunless %}
                          {% endif %}

                        {% endfor %}</div>"
      expect(partial.plugin_names).to match_array ['Nd_0', 'chill', 'Nd_1']
    end
  end

end
