# frozen_string_literal: true
require 'rails_helper'

describe Language do
  describe 'validations' do
    subject { build(:language) }

    it 'is valid' do
      expect(subject).to be_valid
    end

    context 'blank is not allowed for' do
      %w{code name actionkit_uri}.each do |attr|
        it "#{attr}" do
          subject.send("#{attr}=", '')
          expect(subject).to_not be_valid
        end
      end
    end

    context 'nil is not allowed for' do
      %w{code name actionkit_uri}.each do |attr|
        it "#{attr}" do
          subject.send("#{attr}=", nil)
          expect(subject).to_not be_valid
        end
      end
    end
  end
end

