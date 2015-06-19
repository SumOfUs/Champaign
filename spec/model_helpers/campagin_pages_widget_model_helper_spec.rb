require 'spec_helper'
require_relative '../../lib/model_helpers/campaign_pages_widget_model_helper'

RSpec.describe 'Campaign Pages Widget Model Helper', type: :helper do
  it 'Effectively identifes non-URL file locations which need to be modified' do
    contents = {
        image_url: 'http://i.imgur.com/6GvZ4Ur.jpg'
    }
    expect(image_name_valid(contents)).to equal(true)
  end

  it 'Effectively recognizes when there is no image present' do
    contents = {
        foo: 'bar'
    }
    expect(image_name_valid(contents)).to equal(true)
  end

  it 'Effectively recognizes when there is a UUID present' do
    uuid = SecureRandom.uuid
    contents = {
        image_url: uuid.to_s
    }
    expect(image_name_valid(contents)).to equal(true)

    concat_string = 'This is a string to concatenate with a UUID'
    contents[:image_url] = concat_string + uuid.to_s

    expect(image_name_valid(contents)).to equal(true)
  end

  it 'can add a uuid to an image file name' do
    image_file_name = 'test_image.png'
    modified_file_name = add_uuid_to_filename image_file_name
    expect(image_has_uuid(modified_file_name)).to equal(true)
    expect(modified_file_name.split('.')[-1]).to eq('png')
  end

  it 'elegantly handles file names with multiple periods' do
    image_file_name = 'test.image.png'
    modified_file_name = add_uuid_to_filename image_file_name
    expect(image_has_uuid(modified_file_name)).to equal(true)
    expect(modified_file_name.split('.')[-1]).to eq('png')
  end

  it 'elegantly handles file names with no periods' do
    image_file_name = 'test_file_name_with_no_periods'
    modified_file_name = add_uuid_to_filename image_file_name
    expect(image_has_uuid(modified_file_name)).to equal(true)
    expect(modified_file_name.split('.').length).to eq(1)
  end
end
