require 'rails_helper'

describe CampaignPageBuilder do

  subject { CampaignPageBuilder.create_with_plugins(params) }

  let(:params) {{ title: "Foo Bar", liquid_layout_id: template.id }}
  let(:content) { "{% include 'action' %}<div class='foo'>{% include 'thermometer' %}</div>"}
  let(:template) { create :liquid_layout, content: content }

  before :each do
    create :liquid_partial, title: 'action', content: '{{ plugins.action[ref].lol }}'
    create :liquid_partial, title: 'thermometer', content: '{{ plugins.thermometer[ref].lol }}'

    create(:liquid_layout, :master)
    allow(ChampaignQueue).to receive(:push)
  end

  it 'creates a campaign page' do
    expect { subject }.to change{ CampaignPage.count }.from(0).to(1)
    expect(CampaignPage.first.title).to eq("Foo Bar")
  end

  it "pushes page to queue" do
    expect( ChampaignQueue ).to receive(:push)
    subject
  end

  it 'uses the correct liquid layout' do
    subject
    puts LiquidLayout.last.attributes
    puts CampaignPage.last.attributes
    puts CampaignPage.last.liquid_layout
    puts CampaignPage.last.liquid_layout.content
    puts CampaignPage.last.liquid_layout.partial_refs
    expect(CampaignPage.last.liquid_layout_id).to eq template.id
    expect(CampaignPage.last.liquid_layout).not_to eq LiquidLayout.master
  end

  it 'uses the master template if none specified' do
    params.delete :liquid_layout_id
    expect { subject }.to change{ CampaignPage.count }.from(0).to(1)
    expect(CampaignPage.last.liquid_layout).to eq LiquidLayout.master
  end

  [Plugins::Thermometer, Plugins::Action].each do |plugin|
    it "creates a #{plugin.name}" do
      expect { subject }.to change{ plugin.count }.by 1
    end
  end
end
