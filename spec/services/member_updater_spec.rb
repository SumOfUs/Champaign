# frozen_string_literal: true

require 'rails_helper'

describe MemberUpdater do
  let(:email) { 'asdf@test.com' }
  let(:base_params) { { email: email, postal: '90019', country: 'US' } }
  let(:more_params) { { action_hair_color: 'blonde', phone: '2135551234' } }

  describe '.run' do
    %i[new existing].each do |status, member|
      describe "with #{status} member" do
        let(:new_member) { Member.new(email: email) }
        let(:existing_member) { create(:member, email: email) }

        it 'updates with basic fields' do
          member = (status == :new ? new_member : existing_member)
          MemberUpdater.run(member, base_params)
          expect(member).to be_persisted
          expect(member.attributes.symbolize_keys).to match(hash_including(base_params))
        end

        it 'stores appropriate extra fields in the `more` field' do
          member = (status == :new ? new_member : existing_member)
          extraneous_params = { form_id: 123, jank: 'yank' }
          MemberUpdater.run(member, base_params.merge(extraneous_params).merge(more_params))
          expect(member).to be_persisted
          expect(member.more).to eq more_params.stringify_keys
        end

        it 'updates the more field while respecting existing contents' do
          member = (status == :new ? new_member : existing_member)
          member.more = { action_fun_fact: 'the young pope can juggle', phone: '1112224444' }
          member.save if member.persisted?
          MemberUpdater.run(member, base_params.merge(more_params))
          expect(member).to be_persisted
          expect(member.more).to eq more_params.merge(action_fun_fact: 'the young pope can juggle').stringify_keys
        end
      end
    end
  end

  describe 'member_attributes' do
    let(:updater) { MemberUpdater.new(double('member'), {}) }

    it 'returns symbols' do
      expect(updater.send(:member_attributes).map(&:class).uniq).to eq [Symbol]
    end

    it 'does not include the id' do
      expect(updater.send(:member_attributes)).not_to include(:id)
    end

    it 'includes all the other keys of member' do
      expect(updater.send(:member_attributes))
        .to include(
          :email,
          :country,
          :first_name,
          :last_name,
          :city,
          :postal,
          :title,
          :address1,
          :address2,
          :actionkit_user_id
        )
    end
  end
end
