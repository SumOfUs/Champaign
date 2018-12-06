# frozen_string_literal: true

require 'rails_helper'

require Rails.root.join 'db/migrate/20181205144737_add_thermometers_to_old_fundraisers.rb'

describe AddThermometersToOldFundraisers do
  let!(:body_partial) { create :liquid_partial, title: 'body_text', content: '<p>{{ content }}</p>' }
  let!(:fundraiser_partial) { create :liquid_partial, title: 'fundraiser', content: '{{ plugins.fundraiser[ref] }}' }

  let!(:non_fundraiser_layout) { create :liquid_layout, content: "<h1>{{ title }}</h1> {% include 'body_text' %}" }
  let!(:fundraiser_layout) { create :liquid_layout, content: "<h1>{{ title }}</h1> {% include 'fundraiser' %}" }

  let!(:petition_page) { create(:page, liquid_layout: non_fundraiser_layout) }
  let!(:old_fundraiser_page) { create(:page, liquid_layout: fundraiser_layout) }
  let!(:thermo_fundraiser_page) { create(:page, liquid_layout: fundraiser_layout) }

  subject { AddThermometersToOldFundraisers.new.change }

  before do
    # This is the old fundraiser page that shouldn't have a thermometer
    Plugins::DonationsThermometer.find_by(page_id: old_fundraiser_page).destroy!
  end

  it 'adds donations thermometers to existing fundraisers' do
    expect { subject }
      .to change { Plugins::DonationsThermometer.where(page_id: old_fundraiser_page.id).count }.from(0).to(1)
  end

  it 'does not add donations thermometers to non-fundraiser pages' do
    expect { subject }
      .to_not change { Plugins::DonationsThermometer.where(page_id: petition_page.id).count }.from(0)
  end

  it 'does not add thermometers to pages that already have them' do
    expect { subject }
      .to_not change { Plugins::DonationsThermometer.where(page_id: thermo_fundraiser_page.id).count }.from(1)
  end
end
