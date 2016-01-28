require 'rails_helper'

describe Action do
  let(:page) { create :page }

  it 'increases the action_count after creation' do
    create :action, page_id: page.id
    expect(page.reload.action_count).to eq 1
    create :action, page_id: page.id
    expect(page.reload.action_count).to eq 2
  end

  it 'does not change the page updated_at or cache_key after creation' do
    timestamp = page.updated_at
    key = page.cache_key
    create :action, page_id: page.id
    expect(page.reload.cache_key).to eq key
    expect(page.reload.updated_at).to eq timestamp
    create :action, page_id: page.id
    expect(page.reload.cache_key).to eq key
    expect(page.reload.updated_at).to eq timestamp
  end
end
