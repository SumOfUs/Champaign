# frozen_string_literal: true

# == Schema Information
#
# Table name: pending_actions
#
#  id           :bigint(8)        not null, primary key
#  bounced_at   :datetime
#  clicked      :string           default([]), is an Array
#  complaint    :boolean
#  confirmed_at :datetime
#  consented    :boolean
#  data         :jsonb
#  delivered_at :datetime
#  email        :string
#  email_count  :integer          default(0)
#  emailed_at   :datetime
#  opened_at    :datetime
#  token        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  page_id      :bigint(8)
#
# Indexes
#
#  index_pending_actions_on_page_id  (page_id)
#

require 'rails_helper'

describe PendingAction do
  describe 'scopes' do
    describe :not_confirmed do
      it 'returns records where not_confirmed is nil' do
        create(:pending_action, confirmed_at: Time.now)
        not_confirmed = create(:pending_action, confirmed_at: nil)

        expect(PendingAction.not_confirmed).to eq([not_confirmed])
      end
    end

    describe :only_emailed_once do
      it 'returns records where not_confirmed is nil and email_count is 1' do
        emailed_once = create(:pending_action, email_count: 1)
        create(:pending_action, email_count: 2)

        expect(PendingAction.only_emailed_once).to eq([emailed_once])
      end
    end

    describe :not_emailed_last_24 do
      it 'returns records where emailed_at greater than 24 hours' do
        Timecop.freeze do
          create(:pending_action, emailed_at: 2.hours.ago)
          create(:pending_action, emailed_at: 24.hours.ago)
          emailed_after_24 = create(:pending_action, emailed_at: 25.hours.ago)

          expect(PendingAction.not_emailed_last_24).to eq([emailed_after_24])
        end
      end
    end
  end
end
