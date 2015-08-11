require 'rails_helper'

describe LiquidLayout do

  let(:template) { LiquidLayout.new(title: "My template", content: "placeholder") }
  let(:example_html_top) { 
    %Q{<div class="content">
        <div id="foo"></div>
        <div class="header slot3">}
  }
  let(:example_html_bottom) {
    %Q{</div>
      </div>}
  }
    

  describe "is valid" do

    after :each do
      expect(template).to be_valid
    end

    it "with just template and content" do
    end

    describe "with slot tags" do

      after :each do
        template.content = "#{example_html_top}#{@example}#{example_html_bottom}"
      end

      it "that start with 1" do
        @example = "{{ slot1 }}"
      end

      it "with numbers 1-3" do
        @example = "{{ slot1 }}<div class='subarea'>{{slot2}}</div>{{ slot3 }}"
      end

      it "with ordered nubers in unordered tags" do
        @example = "{{ slot3 }}<div class='subarea'>{{slot1}}</div>{{ slot2 }}"
      end

      it "with a slot tag that doesn't get recognized" do
        @example = "{{ slot }}"
      end
    end

  end

  describe "is invalid" do

    after :each do
      expect(template).to be_invalid
    end

    it "with empty string title" do
      template.title = ""
    end

    it "with nil title" do
      template.title = nil
    end

    it "with empty string content" do
      template.content = ""
    end

    it "with nil content" do
      template.content = nil
    end

    describe "with bad slot tags" do

      after :each do
        template.content = "#{example_html_top}#{@example}#{example_html_bottom}"
      end

      it "if slot starts with 0" do
        @example = "{{ slot0 }}"
      end

      it "if slots skip a number" do
        @example = "{{ slot1 }}<div class='subarea'>{{slot3}}</div>"
      end
    end
  end
  
  describe "slots" do

    describe "finds the slot if it" do

      after :each do
        template.content = "#{example_html_top}#{@example}#{example_html_bottom}"
        expect(template.slot_ids).to eq [1]
      end

      it "has spaces in brackets" do
        @example = '{{ slot1 }} '
      end

      it "does not have spaces in brackets" do
        @example = ' {{slot1}}'
      end

      it "has whitespace around brackets" do
        @example = ' {{slot1 }} '
      end

      it "does not have whitespace around brackets" do
        @example = '{{ slot1}}'
      end

    end

    describe "does not find slot if it" do

      after :each do
        template.content = "#{example_html_top}#{@example}#{example_html_bottom}"
        expect(template.slot_ids).to eq []
      end

      it "does not use the word 'slot'" do
        @example = '{{ 1 }}'
      end

      it "does not have a number" do
        @example = '{{ slot }}'
      end

      it "has an empty tag" do
        @example = '{{ }}'
      end

      it "has spaces between the word slot and the number" do
        @example = '{{ slot 1 }}'
      end
    end

  end
  
  describe "slot labels" do

    describe "finds the slot label if it" do

      after :each do
        @expected ||= "sidebar"
        template.content = "#{example_html_top}#{@example}#{example_html_bottom}"
        expect(template.slot_labels).to eq [@expected]
      end

      it "is on a newline after the slot tag" do
        @example  = %Q{
          {{ slot1 }}
          <!-- sidebar -->
        }
      end

      it "is on the same line after the slot tag" do
        @example  = "{{ slot1 }}<!-- sidebar -->"
      end

      it "is on the same line with spaces after the slot tag" do
        @example  = "{{ slot1 }}   <!-- sidebar -->"
      end

      it "does not have spaces in the html comment" do
        @example  = "{{ slot1 }} <!--sidebar-->"
      end

      it "has numbers, letters, and spaces" do
        @example = "{{ slot1 }} <!-- my sw33t sidebar -->"
        @expected = "my sw33t sidebar"
      end

      it "has dashes and carats" do
        @example = "{{ slot1 }} <!-- <sidebar-slot-3> -->"
        @expected = "<sidebar-slot-3>"
      end
    end

    describe "does not find slot label if it" do

      after :each do
        @expected ||= ["slot 1"]
        template.content = "#{example_html_top}#{@example}#{example_html_bottom}"
        expect(template.slot_labels).to eq @expected
      end

      it "is before the slot tag" do
        @example = "<!--sidebar--> {{ slot1 }}"
      end

      it "does not have a nearby slot tag" do
        @example = "<!--sidebar-->"
        @expected = []
      end

      it "is a multi-line comment" do
        @example  = %Q{
          {{ slot1 }} <!--
            sidebar 
          -->
        }
      end
    end

    it "is correctly ordered even if the slots aren't in ordered" do
      template.content = "#{example_html_top}
        <div class='slot'> {{ slot2 }} <!-- header image --> </div>
        <div class='slot'> {{ slot1 }} <!-- title --> </div>
        <div class='slot'> {{ slot3 }} <!-- body1 --> </div>
      #{example_html_bottom}"
      expect(template.slot_labels).to eq (["title", "header image", "body1"])
    end

  end

end
