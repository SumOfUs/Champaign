# frozen_string_literal: true
# == Schema Information
#
# Table name: share_twitters
#
#  id          :integer          not null, primary key
#  sp_id       :integer
#  page_id     :integer
#  title       :string
#  description :string
#  button_id   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

describe Share::Twitter do
  describe 'validation' do
    subject { build(:share_twitter) }

    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'description must be present' do
      subject.description = nil
      expect(subject).to_not be_valid
    end

    it 'must have {LINK} in description' do
      subject.description = 'Foo'
      expect(subject).to_not be_valid
    end
  end
end
