# frozen_string_literal: true

namespace :champaign do
  desc 'Associate liquid layouts known to be petition or donation forms with their default post-action layouts'
  task associate_layouts: :environment do
    puts 'Associating petition and donation layouts with default post action layouts'

    post_petition_share = LiquidLayout.find_by(title: 'Post Petition Share')
    post_donation_share = LiquidLayout.find_by(title: 'Post Donation Share')

    petition_layouts = LiquidLayout.where(title: ['Petition With Large Image', 'Petition With Small Image'])
    donation_layouts = LiquidLayout.where(title: ['Fundraiser With Large Image', 'Fundraiser With Small Image'])

    # Associate petition_layouts and donation_layouts with their desired default follow up layouts:
    petition_layouts.each do |layout|
      layout.update_attributes(primary_layout: true,
                               post_action_layout: false,
                               default_follow_up_layout: post_petition_share)
      layout.save
    end

    donation_layouts.each do |layout|
      layout.update_attributes(primary_layout: true,
                               post_action_layout: false,
                               default_follow_up_layout: post_donation_share)
      layout.save
    end

    # For post_petition_share and post_donation_share, update primary_layout and post_action_layout
    [post_petition_share, post_donation_share].each do |share_layout|
      share_layout.update_attributes(primary_layout: false,
                                     post_action_layout: true)
    end

    puts 'Finished default follow-up layout associations.'
  end
end
