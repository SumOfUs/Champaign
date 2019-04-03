# frozen_string_literal: true

require 'rails_helper'

# are these tests failing? it could be a breaking change in the liquid API.
# change to version 3.0.x and try again.
describe LiquidTagFinder do
  let(:base_content) do
    %(<section class="wrapper">
        <div class="foo">
          {% include "example" %}
        </div>
        <h2>{{ title }}</h2>
        <div class='bar'>
          {% include 'swell' %}
        </div>
      </section>
      <div>{% for field in plugins.petition.fields %}<p>hey</p>{% endfor %}</div>)
  end

  describe 'plugin_names' do
    after :each do
      actual = LiquidTagFinder.new(@content).plugin_names
      expect(actual).to match_array @expected
    end

    it 'finds a plugin in a basic variable tag' do
      @content  = '<div>{{ plugins.example.content }}</div>'
      @expected = ['example']
    end

    it 'finds a plugin in a for loop tag' do
      @content  = '<div>{% for field in plugins.petition.fields %}<p>hey</p>{% endfor %}</div>'
      @expected = ['petition']
    end

    it 'finds a plugin with underscores, numbers, and capital letters in the name' do
      @content  = '<div>{{ plugins.my_exAMPle_2.content }}</div>'
      @expected = ['my_exAMPle_2']
    end

    it 'finds a plugin in a for loop tag' do
      @content  = '<div>{% for field in plugins.petition.fields %}<p>hey</p>{% endfor %}</div>'
      @expected = ['petition']
    end

    it 'finds a plugin referenced twice in the same way' do
      @content  = '<div>{{ plugins.Nd_0.title }}<p>{{ plugins.Nd_0.title }}</p></div>'
      @expected = ['Nd_0']
    end

    it 'finds a plugin nested in a ref to the same plugin' do
      @content  = '<div>{% for field in plugins.Nd_0.fields %}<p>{{ plugins.Nd_0.title }}</p>{% endfor %}</div>'
      @expected = ['Nd_0']
    end

    it 'finds a plugin nested in a ref to the same plugin' do
      @content  = '<div>{% for field in plugins.Nd_0.fields %}<p>{{ plugins.chill.title }}</p>{% endfor %}</div>'
      @expected = %w[Nd_0 chill]
    end

    it 'finds plugin nested deeply' do
      @content = "{% for field in plugins.Nd_0.fields %}
                    {% if plugins.Nd_0.is_chill %}
                      <h2>{{ plugins.chill.title }}</h2>
                    {% else %}
                      {% unless field == 'derp' %}
                        {{ plugins.Nd_1 }}
                        {% include 'something' %}
                      {% endunless %}
                    {% endif %}
                  {% endfor %}"
      @expected = %w[Nd_0 chill Nd_1]
    end
  end

  describe 'partial_names' do
    after :each do
      actual = LiquidTagFinder.new(@content).partial_names
      expect(actual).to eq @expected
    end

    it 'finds a single include tag that uses single quotes' do
      @content  = "<div class='foo'>{% include 'example' %}</div>"
      @expected = ['example']
    end

    it 'finds a single include tag that uses double quotes' do
      @content  = '<div class="foo">{% include "example" %}</div>'
      @expected = ['example']
    end

    it 'finds a single include tag that passes a parameter' do
      @content  = '<div class="foo">{% include "my-template", color: "#f3a900" %}</div>'
      @expected = ['my-template']
    end

    it 'finds two tags without matching a variable' do
      @content = %(<section class="wrapper">
                      <div class="foo">
                        {% include "example" %}
                      </div>
                      <h2>{{ title }}</h2>
                      <div class='bar'>
                        {% include 'swell' %}
                      </div>
                    </section>)
      @expected = %w[example swell]
    end
  end

  describe 'partial_refs' do
    let(:nested_top) do
      %( {% for field in plugins.Nd_0.fields %}
            {% if plugins.Nd_0.is_chill %}
              <h2>{{ plugins.chill.title }}</h2>
            {% else %}
              {% unless field == 'derp' %}
                {{ plugins.Nd_1 }} )
    end
    let(:nested_bottom) do
      %(     {% endunless %}
            {% endif %}
          {% endfor %} )
    end
    let(:surrounding) { { simple: ['', ''], nested: [nested_top, nested_bottom] } }

    %i[simple nested].each do |nesting|
      describe "with a #{nesting} partial" do
        after :each do
          liquid_markup = "#{surrounding[nesting][0]}#{@content}#{surrounding[nesting][1]}"
          actual = LiquidTagFinder.new(liquid_markup).partial_refs
          expect(actual).to match_array @expected
        end

        it 'finds a single tag with no ref' do
          @content  = "<div class='foo'>{% include 'example' %}</div>"
          @expected = [['example', nil]]
        end

        it 'finds a single tag with a ref' do
          @content  = "<div class='foo'>{% include 'example', ref: 'juiz' %}</div>"
          @expected = [%w[example juiz]]
        end

        it 'finds a single tag with another parameter and a ref' do
          @content  = "<div class='foo'>{% include 'example', color: '#43ab05', ref: 'juiz' %}</div>"
          @expected = [%w[example juiz]]
        end

        it 'finds two of the same includes with different refs' do
          @content  = "{% include 'example', ref: 'zebra' %}<div>{% include 'example', ref: 'juiz' %}</div>"
          @expected = [%w[example zebra], %w[example juiz]]
        end

        it 'finds two of the same includes with one ref' do
          @content  = "{% include 'example', ref: 'zebra' %}<div>{% include 'example' %}</div>"
          @expected = [%w[example zebra], ['example', nil]]
        end

        it 'condenses two same includes with same ref' do
          @content  = "{% include 'example', ref: 'zebra' %}<div>{% include 'example', ref: 'zebra' %}</div>"
          @expected = [%w[example zebra]]
        end

        it 'condenses two same includes with no refs' do
          @content  = "{% include 'example' %}<div>{% include 'example' %}</div>"
          @expected = [['example', nil]]
        end

        it 'finds two different includes with no refs' do
          @content  = "{% include 'example' %}<div>{% include 'la paz' %}</div>"
          @expected = [['example', nil], ['la paz', nil]]
        end

        it 'finds two different includes with different refs' do
          @content  = "{% include 'example', ref: 'zebra' %}<div>{% include 'la paz', ref: 'juiz' %}</div>"
          @expected = [%w[example zebra], ['la paz', 'juiz']]
        end

        it 'finds two different includes with same refs' do
          @content  = "{% include 'example', ref: 'zebra' %}<div>{% include 'la paz', ref: 'juiz' %}</div>"
          @expected = [%w[example zebra], ['la paz', 'juiz']]
        end
      end
    end
  end

  describe 'description' do
    describe 'is found if it' do
      it 'has description in all lower case' do
        tag = '{% comment %} description: oh me oh my!{% endcomment %}'
        description = LiquidTagFinder.new(tag + base_content).description
        expect(description).to eq 'oh me oh my!'
      end

      it 'has description in wonky case' do
        tag = '{% comment %} DescRIPtion: Obla de obla da {% endcomment %}'
        description = LiquidTagFinder.new(tag + base_content).description
        expect(description).to eq 'Obla de obla da'
      end

      it 'has the description tag at the end' do
        tag = '{% comment %}description: ay yai YAI{% endcomment %}'
        description = LiquidTagFinder.new(base_content + tag).description
        expect(description).to eq 'ay yai YAI'
      end

      it 'has the description tag in the middle' do
        tag = '{% comment %}description: The flames crept higher. {% endcomment %}'
        description = LiquidTagFinder.new(base_content + tag + base_content).description
        expect(description).to eq 'The flames crept higher.'
      end

      it 'is the first description tag' do
        tag1 = '{% comment %} description: Led them to the rebel base. {% endcomment %}'
        tag2 = '{% comment %}description: Rebel bass rebel bass. {% endcomment %}'
        description = LiquidTagFinder.new(tag1 + tag2 + base_content).description
        expect(description).to eq 'Led them to the rebel base.'
      end

      it 'comes after an experimental tag' do
        e_tag = '{% comment %} experimental: true {% endcomment %}'
        tag = '{% comment %}description: R&B - rebel and base. {% endcomment %}'
        description = LiquidTagFinder.new(e_tag + tag + base_content).description
        expect(description).to eq 'R&B - rebel and base.'
      end
    end

    describe 'is not found if it' do
      it 'does not have a colon' do
        tag = '{% comment %} description - oh me oh my!{% endcomment %}'
        description = LiquidTagFinder.new(tag + base_content).description
        expect(description).to eq nil
      end

      it 'is not in a liquid comment' do
        tag = '<!-- description: oh me oh my! -->'
        description = LiquidTagFinder.new(tag + base_content).description
        expect(description).to eq nil
      end

      it 'is not included' do
        description = LiquidTagFinder.new(base_content).description
        expect(description).to eq nil
      end
    end
  end

  describe 'experimental?' do
    it 'returns true if experimental is "true"' do
      tag = '{% comment %} experimental: true {% endcomment %}'
      expect(LiquidTagFinder.new(tag + base_content).experimental?).to eq true
    end

    it 'returns true if experimental is "TRUE"' do
      tag = '{% comment %} experimental: TRUE {% endcomment %}'
      expect(LiquidTagFinder.new(tag + base_content).experimental?).to eq true
    end

    it 'returns false if experimental is 1' do
      tag = '{% comment %} experimental: 1 {% endcomment %}'
      expect(LiquidTagFinder.new(tag + base_content).experimental?).to eq false
    end

    it 'returns false if experimental tag is absent' do
      expect(LiquidTagFinder.new(base_content).experimental?).to eq false
    end
  end

  describe 'primary_layout?' do
    it 'returns true if primary layout is "true"' do
      tag = '{% comment %} Primary layout: true {% endcomment %}'
      expect(LiquidTagFinder.new(tag + base_content).primary_layout?).to eq true
    end

    it 'returns false if primary_layout tag is absent' do
      expect(LiquidTagFinder.new(base_content).primary_layout?).to eq false
    end
  end

  describe 'post_action_layout?' do
    it 'returns true if post-action layout is "true"' do
      tag = '{% comment %} Post-action layout: true {% endcomment %}'
      expect(LiquidTagFinder.new(tag + base_content).post_action_layout?).to eq true
    end

    it 'returns false if post_action_layout tag is absent' do
      expect(LiquidTagFinder.new(base_content).post_action_layout?).to eq false
    end
  end
end
