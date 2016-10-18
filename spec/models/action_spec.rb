# frozen_string_literal: true
# == Schema Information
#
# Table name: actions
#
#  id                :integer          not null, primary key
#  page_id           :integer
#  member_id         :integer
#  link              :string
#  created_user      :boolean
#  subscribed_user   :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  form_data         :jsonb
#  subscribed_member :boolean          default(TRUE)
#  donation          :boolean          default(FALSE)
#

require 'rails_helper'

describe Action do
  let(:page) { create :page }
  let(:member) { create :member }

  describe 'on create' do
    describe 'counter_cache on page' do
      subject { create(:action, page_id: page.id, member_id: member.id) }

      it 'increases the action_count after creation' do
        expect { subject }.to change { page.reload.action_count }.from(0).to(1)
      end

      it 'does not stamp updated_at' do
        expect { subject }.not_to change { page.reload.updated_at }
      end

      it 'does not change cache_key' do
        expect { subject }.not_to change { page.reload.cache_key }
      end
    end
  end

  describe 'scopes' do
    let!(:donation_action) { create(:action, page_id: page.id, member_id: member.id, donation: true) }
    let!(:non_donation_action) { create(:action, page_id: page.id, member_id: member.id, donation: false) }
    describe 'donation' do
      it 'lists only donation actions' do
        expect(Action.donation).to match([donation_action])
      end
    end
    describe 'not_donation' do
      it 'lists only actions that are not donations' do
        expect(Action.not_donation).to match([non_donation_action])
      end
    end
  end
end
