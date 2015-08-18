require 'rails_helper'

describe CampaignPageBuilder do
  before do
    allow(ChampaignQueue).to receive(:push)
  end

  let(:template) { create :liquid_layout }
  let(:params) {{ title: "Foo Bar", liquid_layout_id: template.id }}
  subject { CampaignPageBuilder.create_with_plugins(params) }

  it 'creates a campaign page' do
    expect {
      subject
    }.to change{ CampaignPage.count }.from(0).to(1)

    expect(CampaignPage.first.title).to eq("Foo Bar")
  end

  it "pushes page to queue" do
    expect( ChampaignQueue ).to receive(:push)

    subject
  end

  [Plugins::Thermometer, Plugins::Action].each do |plugin|
    it "creates #{plugin.name}" do
      expect {
        subject
      }.to change{ plugin.count }.by 0
    end
  end

end
