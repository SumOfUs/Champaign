require_relative '../../../queue_listeners/lib/crm_page'

describe CrmPage do
  let(:first_page) { CrmPage.new }
  let(:second_page) { CrmPage.new }
  it 'should be equivalent to an equivalent page' do
    expect(first_page).to eq(second_page)
  end

  it 'should still be equal when we change values' do
    first_example = first_page
    second_example = second_page
    second_example.base_url = 'test'
    first_example.base_url = 'test'
    expect(first_example).to eq(second_example)
  end

  it 'should not be equal when values are different' do
    first_example = first_page
    second_example = second_page
    second_example.base_url = 'test'
    first_example.base_url = 'wrong value'
    expect(first_example).to_not eq(second_example)
  end
end