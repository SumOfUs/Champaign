require_relative '../../../queue_listeners/lib/crm_page'

describe CrmPage do
  let(:first_page) { CrmPage.new }
  let(:second_page) { CrmPage.new }
  let(:crm_id) {1}
  let(:language) {'english'}


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

  it 'should be able to update a single value' do

    test_page = first_page
    test_page.update_values crm_id: crm_id
    default_page = second_page
    default_page.crm_id = crm_id

    expect(test_page).to eq(default_page)
    expect(default_page.crm_id).to eq(crm_id)
    expect(test_page.crm_id).to eq(crm_id)
  end

  it 'should be able to update multiple values' do

    test_page = first_page
    test_page.update_values crm_id: crm_id, language: language
    default_page = second_page
    default_page.crm_id = crm_id
    default_page.language = language
    expect(test_page).to eq(default_page)
    expect(test_page.language).to eq(language)
  end
end
