# frozen_string_literal: true
# == Schema Information
#
# Table name: members
#
#  id                :integer          not null, primary key
#  email             :string
#  country           :string
#  first_name        :string
#  last_name         :string
#  city              :string
#  postal            :string
#  title             :string
#  address1          :string
#  address2          :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  actionkit_user_id :string
#  donor_status      :integer          default(0), not null
#

require 'rails_helper'

describe Member do
  let(:first_name) { 'Emilio' }
  let(:last_name) { 'Estevez' }
  let(:full_name) { "#{first_name} #{last_name}" }
  let(:unicode_first) { 'Éöíñ' }
  let(:unicode_last) { 'Ńūñèž' }
  let(:unicode_full) { "#{unicode_first} #{unicode_last}" }
  let(:chinese_first) { '台' }
  let(:chinese_last) { '北' }
  let(:chinese_full) { "#{chinese_first} #{chinese_last}" }

  describe 'name' do
    it 'correctly joins first and last name' do
      member = Member.new
      member.first_name = first_name
      member.last_name = last_name
      expect(member.name).to eq(full_name)
    end

    it 'correctly splits full_name into first and last name' do
      member = Member.new
      member.name = full_name
      member.save
      new_member = Member.find(member.id)
      expect(new_member.first_name).to eq(first_name)
      expect(new_member.last_name).to eq(last_name)
      expect(new_member.name).to eq(full_name)
    end

    it 'correctly handles unicode characters' do
      member = Member.new
      member.name = unicode_full
      member.save
      new_member = Member.find(member.id)
      expect(new_member.first_name).to eq(unicode_first)
      expect(new_member.last_name).to eq(unicode_last)
      expect(new_member.name).to eq(unicode_full)
    end

    it 'correctly handles high-value unicode characters' do
      member = Member.new
      member.name = chinese_full
      member.save
      new_member = Member.find(member.id)
      expect(new_member.first_name).to eq(chinese_first)
      expect(new_member.last_name).to eq(chinese_last)
      expect(new_member.name).to eq(chinese_full)
    end
  end

  describe 'validations' do
    describe 'email' do
      before do
        create(:member, email: 'foo@example.com')
      end

      context 'uniqueness' do
        it 'must be unique' do
          member = build(:member, email: 'foo@example.com')
          expect { member.save! }.to raise_error(ActiveRecord::RecordInvalid, /Email has already been taken/)
        end

        it 'is not case sensitive' do
          member = build(:member, email: 'Foo@eXample.COM')
          expect { member.save! }.to raise_error(ActiveRecord::RecordInvalid, /Email has already been taken/)
        end
      end

      it 'can be nil' do
        expect do
          create(:member, email: nil)
          create(:member, email: nil)
        end.to_not raise_error
      end
    end
  end

  describe 'liquid_data' do
    it 'includes all attributes, plus name and welcome_name' do
      m = create :member
      expect(m.liquid_data.keys).to match_array(m.attributes.keys.map(&:to_sym) +
                                                [:name, :full_name, :welcome_name, :registered])
    end

    it 'uses name as name if available' do
      m = create :member, name: 'Michelle Foucault', email: 'me@sexualintellectual.com'
      expect(m.liquid_data[:welcome_name]).to eq 'Michelle Foucault'
    end

    it 'uses email as name is name unavailable' do
      m = create :member, name: '', email: 'me@sexualintellectual.com'
      expect(m.liquid_data[:welcome_name]).to eq 'me@sexualintellectual.com'
    end

    it 'includes the donor_status as a string' do
      m = create :member, donor_status: 'nondonor'
      expect(m.liquid_data[:donor_status]).to eq 'nondonor'
    end
  end

  describe 'go_cardless_customer' do
    let(:member) { create :member }

    it 'can have one go_cardless_customer' do
      customer = create :payment_go_cardless_customer, member_id: member.id
      expect(member.reload.go_cardless_customers).to match_array [customer]
    end

    it 'can have several go_cardless_customers' do
      customers = Array.new(3) { create(:payment_go_cardless_customer, member_id: member.id) }
      expect(member.reload.go_cardless_customers).to match_array customers
    end
  end

  describe 'donor_status' do
    let(:member) { create :member }

    it 'defaults to nondonor' do
      expect(member.donor_status).to eq 'nondonor'
    end

    it 'can be set to donor' do
      expect { member.donor! }.to change { member.donor_status }.to 'donor'
    end

    it 'can be set to recurring_donor' do
      expect { member.recurring_donor! }.to change { member.donor_status }.to 'recurring_donor'
    end

    it 'can be set to nondonor' do
      member.donor!
      expect { member.nondonor! }.to change { member.donor_status }.to 'nondonor'
    end
  end

  describe 'authentication' do
    let(:member) { create :member }

    context 'when a member has no authentications' do
      it 'returns `nil`' do
        expect(member.authenticate('password')).to eq(nil)
      end
    end

    context 'when a member has an unconfirmed authentication' do
      it 'returns `false`' do
        member.create_authentication(password: 'password')

        expect(member.authenticate('password')).to be(false)
      end
    end

    context 'when a member has a  confirmed authentication' do
      before do
        member.create_authentication(password: 'password', confirmed_at: Time.now)
      end

      it 'returns `true` when the password matches' do
        expect(member.authenticate('password')).to be(true)
      end

      it 'returns `false` when the password does not match' do
        expect(member.authenticate('invalid_password')).to be(false)
      end

      it 'destroys their authentication when destroyed' do
        MemberAuthentication.create(member: member)
        member.destroy
        expect(MemberAuthentication.find_by(member_id: member.id)).to be(nil)
      end
    end
  end

  describe 'token_payload' do
    let(:member) { create :member }

    it 'returns the { id, email, authentication_id }' do
      expect(member.token_payload).to include(:id, :email, :authentication_id)
    end

    it 'has a nil authentication_id if the user has no authentication' do
      expect(member.token_payload[:authentication_id]).to eq(nil)
    end

    it 'contains their authentication_id if the user has an authentication' do
      member.create_authentication(attributes_for(:member_authentication))

      expect(member.token_payload[:authentication_id]).to(
        eq(MemberAuthentication.last.id)
      )
    end
  end

  describe 'actions association' do
    let(:member) { create(:member) }
    let!(:action1) { create(:action, member: member) }
    let!(:action2) { create(:action, member: member) }
    let!(:action3) { create(:action, member: member) }

    it 'gets actions for member' do
      expect(member.actions).to match_array([action1, action2, action3])
    end
  end
end
