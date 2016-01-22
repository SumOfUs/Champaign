require 'timecop'
require 'redis'

namespace :champaign do
  desc "See sample action data"
  task :seed_actions, [:page_id] => :environment do |task, args|
    puts "Seeding..."
    Redis.new.flushdb

    def new_member?
      rand < 0.125
    end

    def seed_for_moment(page_id, multiplier = 1)
      ((rand(10) * rand(10)) + rand(10) * multiplier).times do
        x = new_member?
        Analytics::Page.increment(page_id, new_member: new_member?)
        print x ? 'x' : '.'
      end
    end

    31.times do |i|
      i += 2
      Timecop.travel( Time.now - i.send(:days) ) do
        seed_for_moment(args.page_id, 40)
      end
    end

    15.times do |i|
      Timecop.travel( Time.now - i.send(:hours) ) do
        seed_for_moment(args.page_id)
      end
    end

    1000.times do
      rand(2).times do
        Analytics::Page.increment(args.page_id, new_member: new_member?)
        print '.'
      end
      sleep 3
    end

    puts
  end
end

