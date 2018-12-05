class AddThermometersToOldFundraisers < ActiveRecord::Migration[5.2]
  def change
    pages = Plugins::Fundraiser.select(:page_id).where.not(page_id: Plugins::DonationsThermometer.select(:page_id))
    batch_page_ids = pages.map { |p| { page_id: p.page_id } }
    Plugins::DonationsThermometer.create!(batch_page_ids)
  end
end
