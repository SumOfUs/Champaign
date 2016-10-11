require 'rails_helper'

describe MemberUpdater do
  describe '#filtered_params' do
    let(:member) { build(:member) }

    it "symbolizes keys" do
      updater = MemberUpdater.new(member, 'email' => 'rod@rod.com')
      expect(updater.send(:filtered_params)).to eq(email: 'rod@rod.com')
    end

    it "disregards unknown params" do
      updater = MemberUpdater.new(member, email: 'rod@rod.com', blerg: false, akid:  '1234.514.lQVxcW')
      expect(updater.send(:filtered_params)).to eq(email: 'rod@rod.com')
    end
  end

  describe 'permitted_keys' do
    let(:updater) { MemberUpdater.new(double("member"), {}) }

    it 'returns symbols' do
      expect(updater.send(:permitted_keys).map(&:class).uniq).to eq [Symbol]
    end

    it 'does not include the id' do
      expect(updater.send(:permitted_keys)).not_to include(:id)
    end

    it 'includes all the other keys of member' do
      expect(updater.send(:permitted_keys))
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
