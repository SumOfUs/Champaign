require 'rails_helper'
require './lib/analytics'

describe Analytics do
  before do
    Analytics.store.flushdb
  end

  subject { Analytics::Page.new('1') }

  describe '#total_actions' do
    before do
      subject.increment_actions(new_member: true)
      2.times{ subject.increment_actions(new_member: false) }
    end

    it 'counts total actions' do
      expect( subject.total_actions ).to eq(3)
    end

    it 'counts new member actions' do
      expect( subject.total_actions(new_members: true) ).to eq(1)
    end
  end

  describe '#total_actions_over_time' do
    context 'by day' do
      before do
        Timecop.freeze('01-01-2000') do
          2.times{ subject.increment_actions }
          subject.increment_actions(new_member: true)

          Timecop.travel(1.day.ago) do
            5.times{ subject.increment_actions }
            3.times{ subject.increment_actions(new_member: true) }
          end

          Timecop.travel(3.days.ago) do
            3.times{ subject.increment_actions }
          end
        end
      end

      it 'returns total actions by day' do
        sample_of_expected_data = {
          '2000-01-01 00:00:00' => 3, '1999-12-31 00:00:00' => 8, '1999-12-29 00:00:00' => 3
        }

        Timecop.freeze('01-01-2000') do
          expect(
            subject.total_actions_over_time(period: :day)
          ).to include( sample_of_expected_data )
        end
      end

      it 'returns actions by new members by day' do
        sample_of_expected_data = {
          '2000-01-01 00:00:00' => 1, '1999-12-31 00:00:00' => 3, '1999-12-29 00:00:00' => 0
        }

        Timecop.freeze('01-01-2000') do
          expect(
            subject.total_actions_over_time(period: :day, new_members: true)
          ).to include( sample_of_expected_data )
        end
      end
    end

    context 'by hour' do
      before do
        Timecop.freeze('02-01-2000') do
          2.times{ subject.increment_actions }
          subject.increment_actions(new_member: true)

          Timecop.travel(1.hour.ago) do
            5.times{ subject.increment_actions }
            3.times{ subject.increment_actions(new_member: true) }
          end

          Timecop.travel(3.hours.ago) do
            3.times{ subject.increment_actions }
          end
        end
      end

      it 'has 12 data points' do
        Timecop.freeze do
          expected_keys = (0..11).inject([]) do |memo, i|
            memo << (Time.now.utc - i.send(:hour)).beginning_of_hour.to_s(:db)
          end

          expect(
            subject.total_actions_over_time(period: :hour).keys
          ).to eq( expected_keys )
        end
      end

      it 'returns total actions by hour' do
        sample_of_expected_data = {
          "2000-01-02 00:00:00" => 3,
          "2000-01-01 23:00:00" => 8,
          "2000-01-01 21:00:00" => 3
        }

        Timecop.freeze('02-01-2000') do
          expect(
            subject.total_actions_over_time(period: :hour)
          ).to include( sample_of_expected_data )
        end
      end

      it 'returns actions by new members by hour' do
        sample_of_expected_data = {
          "2000-01-02 00:00:00" => 1,
          "2000-01-01 23:00:00" => 3
        }


        Timecop.freeze('02-01-2000') do
          expect(
            subject.total_actions_over_time(period: :hour, new_members: true)
          ).to include( sample_of_expected_data )
        end
      end
    end
  end
end

