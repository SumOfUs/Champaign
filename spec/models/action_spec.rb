require 'rails_helper'

describe Action do
  let(:test_liquid_layout) { LiquidLayout.create! title: 'test', content: 'test'}
  let(:page) { Page.create! title: 'test', liquid_layout_id: test_liquid_layout.id }

  it 'increases the action_count after creation' do
    Action.create! page_id: page.id
    expect(Page.find(page.id).action_count).to eq(1)
  end
end
