require 'rails_helper'

describe Member do
  let(:first_name) { 'Emilio' }
  let(:last_name) { 'Estevez' }
  let(:full_name) { "#{first_name} #{last_name}" }
  let(:unicode_first) { 'Éöíñ'}
  let(:unicode_last) { 'Ńūñèž' }
  let(:unicode_full) { "#{unicode_first} #{unicode_last}" }
  let(:chinese_first) { '台'}
  let(:chinese_last) { '北' }
  let(:chinese_full) { "#{chinese_first} #{chinese_last}"}

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

      it 'must be unique' do
        member = build(:member, email: 'foo@example.com')
        expect(member).to be_invalid
        expect(member.errors[:email]).to eq(["has already been taken"])
      end

      it 'can be nil' do
        expect{
          create(:member, email: nil)
          create(:member, email: nil)
        }.to_not raise_error
      end
    end
  end

  describe 'email' do
    it 'is downcased on create' do
      member = create(:member, email: 'FOO@ExAmPle.CoM')
      expect(member.email).to eq('foo@example.com')
    end

    it 'is downcased on save' do
      member = create(:member, email: 'foo@example.com')
      member.update(email: 'FOO@EXAMPLE.ORG')
      expect(member.email).to eq('foo@example.org')
    end

    it 'is fine with nil' do
      expect{
        create(:member, email: nil)
      }.to change{Member.count}.
      from(0).to(1)

      expect(Member.last.email).to be nil
    end
  end

  describe 'liquid_data' do
    it 'includes all attributes, plus name and welcome_name' do
      m = create :member
      expect(m.liquid_data.keys).to match_array(m.attributes.keys + [:name, :full_name, :welcome_name])
    end

    it 'uses name as name if available' do
      m = create :member, name: 'Michelle Foucault', email: 'me@sexualintellectual.com'
      expect(m.liquid_data[:welcome_name]).to eq 'Michelle Foucault'
    end

    it 'uses email as name is name unavailable' do
      m = create :member, name: '', email: 'me@sexualintellectual.com'
      expect(m.liquid_data[:welcome_name]).to eq 'me@sexualintellectual.com'
    end
  end

  describe 'go_cardless_customer' do

    let(:member){ create :member }

    it 'can have one go_cardless_customer' do
      customer = create :payment_go_cardless_customer, member_id: member.id
      expect(member.reload.go_cardless_customers).to match_array [customer]
    end

    it 'can have several go_cardless_customers' do
      customers = 3.times.map { create(:payment_go_cardless_customer, member_id: member.id) }
      expect(member.reload.go_cardless_customers).to match_array customers
    end
  end

  describe 'donor_status' do

    let(:member){ create :member }

    it 'defaults to nondonor' do
      expect(member.donor_status).to eq 'nondonor'
    end

    it 'can be set to donor' do
      expect{ member.donor! }.to change{ member.donor_status }.to 'donor'
    end

    it 'can be set to recurring_donor' do
      expect{ member.recurring_donor! }.to change{ member.donor_status }.to 'recurring_donor'
    end

    it 'can be set to nondonor' do
      member.donor!
      expect{ member.nondonor! }.to change{ member.donor_status }.to 'nondonor'
    end
  end
end
