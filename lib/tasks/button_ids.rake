# frozen_string_literal: true
namespace :champaign do
  desc 'Associate existing shares with their respective button_ids'
  task associate_buttons: :environment do
    Share::Variant.all.each do |variant|
      # ALERT - this needs good testing before running it on production
      variant.button_id = Share::Button.find_by(page_id: variant.page_id, sp_type: variant.class.to_s.demodulize.downcase).id
      variant.save
    end
  end
end
