namespace :follow_up_layouts do

  desc "Associate liquid layouts known to be petition or donation forms with their default post-action layouts"
  task layouts: :environment do
    puts "Associating petition and donation layouts with default post action layouts"

    post_petition_share = LiquidLayout.find_by(title: "Post Petition Share")
    post_donation_share = LiquidLayout.find_by(title: "Post Donation Share")

    petition_layouts = LiquidLayout.where(title: ["Petition With Large Image", "Petition With Small Image"])
    donation_layouts = LiquidLayout.where(title: ["Fundraiser With Large Image", "Fundraiser With Small Image"])

    petition_layouts.each do |layout|
      layout.default_follow_up_layout = post_petition_share
      layout.save
    end

    donation_layouts.each do |layout|
      layout.default_follow_up_layout = post_donation_share
      layout.save
    end

    puts "Finished default follow-up layout associations."
  end
end
