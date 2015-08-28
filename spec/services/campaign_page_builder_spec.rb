require 'rails_helper'

describe CampaignPageBuilder do
  before do
    allow(ChampaignQueue).to receive(:push)
  end

  let(:params) {{ title: "Foo Bar", liquid_layout_id: template.id }}
  subject { CampaignPageBuilder.create_with_plugins(params) }


  describe "with empty template" do

    let(:template) { create :liquid_layout, content: '<div class="foo"></div>' }

    it 'creates a campaign page' do
      expect { subject }.to change{ CampaignPage.count }.from(0).to(1)
      expect(CampaignPage.first.title).to eq("Foo Bar")
    end

    it "pushes page to queue" do
      expect( ChampaignQueue ).to receive(:push)
      subject
    end

    [Plugins::Thermometer, Plugins::Action].each do |plugin|
      it "does not create a #{plugin.name}" do
        expect { subject }.to change{ plugin.count }.by 0
      end
    end

    it 'assigns default (English) language' do
      expect(subject.language.code).to eq('EN')
    end
  end

  describe "with basic template" do

    let(:content) { "{% include 'action' %}<div class='foo'>{% include 'thermometer' %}</div>"}
    let(:template) { create :liquid_layout, content: content }

    before :each do
      create :liquid_partial, title: 'action', content: '{{ plugins.action[ref].lol }}'
      create :liquid_partial, title: 'thermometer', content: '{{ plugins.thermometer[ref].lol }}'
    end

    it 'creates a campaign page' do
      expect { subject }.to change{ CampaignPage.count }.from(0).to(1)
      expect(CampaignPage.first.title).to eq("Foo Bar")
    end

    it "pushes page to queue" do
      expect( ChampaignQueue ).to receive(:push)
      subject
    end

    [Plugins::Thermometer, Plugins::Action].each do |plugin|
      it "creates a #{plugin.name}" do
        expect { subject }.to change{ plugin.count }.by 1
      end
    end
  end
end
