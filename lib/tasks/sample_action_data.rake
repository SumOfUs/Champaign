require 'timecop'
require 'redis'

namespace :champaign do
  desc "See sample action data"
  task :seed_actions, [:page_id] => :environment do |task, args|
    puts "Seeding..."
    Redis.new.flushdb

    def seed_for_moment(page_id)
      ((rand(10) * rand(10)) + rand(10)).times do
        new_member = [true, false, false, false, false].sample
        Analytics::Page.increment(page_id, new_member: new_member)
        print '.'
      end
    end

    13.times do |i|
      i += 1
      Timecop.travel( Time.now - i.send(:days) ) do
        seed_for_moment(args.page_id)
      end
    end

    15.times do |i|
      Timecop.travel( Time.now - i.send(:hours) ) do
        seed_for_moment(args.page_id)
      end
    end

    1000.times do
      new_member = [true, false, false, false, false].sample
      rand(2).times do
        Analytics::Page.increment(args.page_id, new_member: new_member)
        print '.'
      end
      sleep 3
    end

    puts
  end
end

