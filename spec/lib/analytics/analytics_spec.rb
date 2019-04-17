# frozen_string_literal: true

require 'rails_helper'

describe Analytics do
  before do
    Analytics.store.flushdb
  end

  let(:start_date) { Time.utc('2000/01/01') }

  subject { Analytics::Page.new('1') }

  describe 'totals' do
    before do
      subject.increment_actions(new_member: true)
      2.times { subject.increment_actions(new_member: false) }
    end

    it 'counts actions' do
      expect(subject.total_actions).to eq(3)
    end

    it 'counts new members' do
      expect(subject.total_new_members).to eq(1)
    end
  end

  describe 'totals over time' do
    context 'by day' do
      before do
        Timecop.freeze(start_date) do
          2.times { subject.increment_actions }
          subject.increment_actions(new_member: true)

          Timecop.travel(1.day.ago) do
            5.times { subject.increment_actions }
            3.times { subject.increment_actions(new_member: true) }
          end

          Timecop.travel(3.days.ago) do
            3.times { subject.increment_actions }
          end
        end
      end

      it 'counts actions by day' do
        sample_of_expected_data = {
          '2000-01-01 00:00:00' => 3, '1999-12-31 00:00:00' => 8, '1999-12-29 00:00:00' => 3
        }

        Timecop.freeze(start_date) do
          expect(
            subject.total_actions_over_time(period: :day)
          ).to include(sample_of_expected_data)
        end
      end

      it 'counts new members by day' do
        sample_of_expected_data = {
          '2000-01-01 00:00:00' => 1, '1999-12-31 00:00:00' => 3, '1999-12-29 00:00:00' => 0
        }

        Timecop.freeze(start_date) do
          expect(
            subject.total_new_members_over_time(period: :day)
          ).to include(sample_of_expected_data)
        end
      end
    end

    context 'by hour' do
      before do
        Timecop.freeze(start_date) do
          2.times { subject.increment_actions }
          subject.increment_actions(new_member: true)

          Timecop.travel(1.hour.ago) do
            5.times { subject.increment_actions }
            3.times { subject.increment_actions(new_member: true) }
          end

          Timecop.travel(3.hours.ago) do
            3.times { subject.increment_actions }
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
          ).to eq(expected_keys)
        end
      end

      it 'actions by hour' do
        sample_of_expected_data = {
          '2000-01-01 00:00:00' => 3,
          '1999-12-31 23:00:00' => 8,
          '1999-12-31 21:00:00' => 3
        }

        Timecop.freeze(start_date).utc do
          expect(
            subject.total_actions_over_time(period: :hour)
          ).to include(sample_of_expected_data)
        end
      end

      it 'members by hour' do
        sample_of_expected_data = {
          '2000-01-01 00:00:00' => 1,
          '1999-12-31 23:00:00' => 3
        }

        Timecop.freeze(start_date).utc do
          expect(
            subject.total_new_members_over_time(period: :hour)
          ).to include(sample_of_expected_data)
        end
      end
    end
  end
end
