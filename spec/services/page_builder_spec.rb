require 'rails_helper'

describe PageBuilder do
  let(:language) { create(:language) }
  let(:params) {{ title: "Foo Bar", liquid_layout_id: template.id, language_id: language.id }}
  let(:content) { "{% include 'petition' %}<div class='foo'>{% include 'thermometer' %}</div>"}
  let(:template) { create :liquid_layout, content: content }

  before :each do
    create :liquid_partial, title: 'petition', content: '{{ plugins.petition[ref].lol }}'
    create :liquid_partial, title: 'thermometer', content: '{{ plugins.thermometer[ref].lol }}'

    create(:liquid_layout, :default)
    allow(QueueManager).to receive(:push)
  end

  subject { PageBuilder.create(params) }

  it 'creates a campaign page' do
    expect { subject }.to change{ Page.count }.from(0).to(1)
    expect(Page.first.title).to eq("Foo Bar")
  end

  it "pushes page to queue" do
    subject

    expect( QueueManager ).to have_received(:push).with(Page.first, job_type: :create)
  end

  it 'uses the correct liquid layout' do
    subject
    expect(Page.last.liquid_layout_id).to eq template.id
  end

  [Plugins::Thermometer, Plugins::Petition].each do |plugin|
    it "creates a #{plugin.name}" do
      expect { subject }.to change{ plugin.count }.by 1
    end
  end
end
