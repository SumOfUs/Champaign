require 'rails_helper'

describe Action do
  let(:page) { create :page }

  it 'increases the action_count after creation' do
    create :action, page_id: page.id
    expect(page.reload.action_count).to eq 1
    create :action, page_id: page.id
    expect(page.reload.action_count).to eq 2
  end
end
