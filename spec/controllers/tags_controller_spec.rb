require 'rails_helper'
require 'capybara/poltergeist'
require 'helper_functions'

RSpec.describe TagsController, type: :request do
  it 'Should provide a list of possible tags' do
    create_tags
    get '/tags/search/welcome'
    expect(response.body).to eq(Tag.where(tag_name: '*Welcome_Sequence').to_json)
  end

  it 'Should provide an empty list if no tags are found' do
    create_tags
    get '/tags/search/not_a_valid_term'
    expect(response.body).to eq([].to_json)
  end
end
