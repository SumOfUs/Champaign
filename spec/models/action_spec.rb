# frozen_string_literal: true

# == Schema Information
#
# Table name: actions
#
#  id                :integer          not null, primary key
#  created_user      :boolean
#  donation          :boolean          default(FALSE)
#  form_data         :jsonb
#  link              :string
#  publish_status    :integer          default("default"), not null
#  subscribed_member :boolean          default(TRUE)
#  subscribed_user   :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  member_id         :integer
#  page_id           :integer
#
# Indexes
#
#  index_actions_on_member_id  (member_id)
#  index_actions_on_page_id    (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (member_id => members.id)
#  fk_rails_...  (page_id => pages.id)
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
