require 'rails_helper'

describe "pages" do
  let(:english)     { create :language }
  let(:page_params) { { title: 'Away we go!', language_id: english.id } }

  describe 'POST create' do
    it 'has the right follow-up url if liquid layout has a default follow-up url' do
      follow_up_layout = create :liquid_layout, default_follow_up_layout: nil
      liquid_layout = create :liquid_layout, default_follow_up_layout: follow_up_layout
      expect {
        post pages_path, page: page_params.merge(liquid_layout_id: liquid_layout.id)
      }.to change{ Page.count }.by 1
      page = Page.last
      expect(PageFollower.new_from_page(page).follow_up_path).to eq "/a/#{page.slug}/follow-up"
    end

    it 'has a blank follow-up url if liquid layout has no default follow-up url' do
      liquid_layout = create :liquid_layout, default_follow_up_layout: nil
      expect {
        post pages_path, page: page_params.merge(liquid_layout_id: liquid_layout.id)
      }.to change{ Page.count }.by 1
      page = Page.last
      expect(PageFollower.new_from_page(page).follow_up_path).to be_nil
    end
  end
end
