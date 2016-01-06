require 'spec_helper'
require './lib/analytics/analytics'

describe Analytics do
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
          '01/01' => 3, '31/12' => 8, '29/12' => 3
        }

        Timecop.freeze('01-01-2000') do
          expect(
            subject.total_actions_over_time(period: :day)
          ).to include( sample_of_expected_data )
        end
      end

      it 'returns actions by new members by day' do
        sample_of_expected_data = {
          '01/01' => 1, '31/12' => 3, '29/12' => 0
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
        Timecop.freeze('01-01-2000') do
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
        expect(
          subject.total_actions_over_time(period: :hour).keys
        ).to eq( (0..11).to_a )
      end

      it 'returns total actions by hour' do
        sample_of_expected_data = {
          0 => 3, 1 => 8, 3 => 3
        }

        Timecop.freeze('01-01-2000') do
          expect(
            subject.total_actions_over_time(period: :hour)
          ).to include( sample_of_expected_data )
        end
      end

      it 'returns actions by new members by hour' do
        sample_of_expected_data = {
          0 => 1, 1 => 3
        }

        Timecop.freeze('01-01-2000') do
          expect(
            subject.total_actions_over_time(period: :hour, new_members: true)
          ).to include( sample_of_expected_data )
        end
      end
    end
  end
end

