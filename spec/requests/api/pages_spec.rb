require 'rails_helper'

describe "api/pages" do

  describe 'GET featured' do
    let!(:popular_page) { create :page, title: 'I am a featured page, AMA', featured: true }
    let!(:less_cool_page) { create :page, title: 'I am not so popular. Sob.'}

    it 'gets only the featured page' do
      get api_pages_path
    end
  end

  describe 'GET pages' do
    let!(:popular_page) { create :page, title: 'I am a featured page, AMA', featured: true }
    let!(:less_cool_page) { create :page, title: 'I am not so popular. Sob.'}

    it 'gets 100 most recent pages if requested without an id' do
      get api_pages_featured_path
    end
  end
end
