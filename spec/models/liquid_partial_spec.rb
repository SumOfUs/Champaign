require 'rails_helper'

describe LiquidPartial do
  
  let(:partial) { create(:liquid_partial) }

  subject{ partial }

  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :content }
  it { is_expected.to respond_to :plugin_name }
  it { is_expected.to respond_to :partial_names }
  it { is_expected.to respond_to :partial_refs }

  it { is_expected.not_to respond_to :one_plugin }

  describe "is valid" do

    after :each do
      expect(partial).to be_valid
    end

    it "with factory settings" do
    end

    it "with multiple references to the same plugin" do
      partial.content = "<div>{{ plugins.actions[ref].text }}</div>
                         <div>{{ plugins.actions[ref].wink }}</div>"
    end

    it "with a reference to a partial that does exist" do
      create :liquid_partial, title: 'existent'
      partial.content = "<div>{% include 'existent' %}</div>"
    end
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

    it "with multiple references to different plugins" do
      partial.content = "<div>{{ plugins.actions[ref].text }}</div>
                         <div>{{ plugins.thermometer[ref].wink }}</div>"
    end

    it "with a reference to a partial that doesn't exist" do
      partial.content = "<div>{% include 'nonexistent' %}</div>"
    end
  end

  describe "plugin refs" do

  end

  describe "missing_partials" do

    it "filters out none if none exist" do
      nonexistent = ['fake', 'not_a_real_partial', 'seriouslyyy']
      expect(LiquidPartial.missing_partials(nonexistent)).to eq nonexistent
    end

    it "filters out all if none exist" do
      p1 = create :liquid_partial
      p2 = create :liquid_partial
      p3 = create :liquid_partial
      expect(LiquidPartial.missing_partials([p1, p2, p3].map(&:title))).to eq []
    end

    it "filters out only nonexistent" do
      p1 = create :liquid_partial
      p2 = create :liquid_partial
      expect(LiquidPartial.missing_partials([p1.title, 'lies', p2.title])).to eq ['lies']
    end

  end


end
