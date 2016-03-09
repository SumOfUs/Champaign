namespace :champaign do
  desc "Associate existing shares with their respective button_ids"
  task associate_buttons: :environment do
    Share::Variant.all.each do |variant|
      variant.button_id = Share::Button.where(page_id: variant.page_id, sp_type: variant.class.to_s.demodulize.downcase).first.id
      variant.save
    end
  end
end
