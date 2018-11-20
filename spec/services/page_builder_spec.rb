# frozen_string_literal: true

require 'rails_helper'

describe PageBuilder do
  let(:language) { create(:language) }
  let(:params) { { title: 'Foo Bar', liquid_layout_id: template.id, language_id: language.id } }
  let(:content) { "{% include 'petition' %}<div class='foo'>{% include 'thermometer' %}</div>" }
  let(:follow_up_template) { create :liquid_layout, default_follow_up_layout: nil }
  let(:template) { create :liquid_layout, content: content, default_follow_up_layout: follow_up_template }

  before :each do
    create :liquid_partial, title: 'petition', content: '{{ plugins.petition[ref].lol }}'
    create :liquid_partial, title: 'thermometer', content: '{{ plugins.thermometer[ref].lol }}'

    create(:liquid_layout, :default)
    allow(QueueManager).to receive(:push)
  end

  subject { PageBuilder.create(params) }

  it 'creates a campaign page' do
    expect { subject }.to change { Page.count }.from(0).to(1)
    expect(Page.first.title).to eq('Foo Bar')
  end

  it 'pushes page to queue' do
    subject

    expect(QueueManager).to have_received(:push).with(Page.first, job_type: :create)
  end

  it 'uses the correct liquid layout' do
    subject
    expect(Page.last.liquid_layout_id).to eq template.id
  end

  [Plugins::ActionsThermometer, Plugins::Petition].each do |plugin|
    it "creates a #{plugin.name}" do
      expect { subject }.to change { plugin.count }.by 1
    end
  end

  it 'sets follow up layout for a page created with a layout that has a default post-action layout' do
    subject
    expect(Page.first.follow_up_liquid_layout_id).to eq(follow_up_template.id)
    # follow-up plan is 'with liquid'
    expect(Page.first.follow_up_plan).to eq 'with_liquid'
  end

  it 'sets no follow up layout for a page created with a layout that has no default post-action layout' do
    params[:liquid_layout_id] = follow_up_template.id
    PageBuilder.create(params)
    expect(Page.first.follow_up_liquid_layout_id).to be nil
    # follow up page hasn't yet been set at this step and should be nil
    expect(Page.first.follow_up_page).to be nil
  end

  it 'creates no page and throws no error for when there is an attempt to create a page without a liquid layout' do
    params[:liquid_layout_id] = nil
    expect { subject }.not_to raise_error
    expect { subject }.not_to change { Page.count }
  end
end
