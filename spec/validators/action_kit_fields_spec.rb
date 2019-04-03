# frozen_string_literal: true

require 'rails_helper'

describe ActionKitFields do
  let(:test_model) do
    Class.new do
      include ActiveModel::Model
      validates_with ActionKitFields

      attr_accessor :name
    end
  end

  subject { test_model }

  context 'with predefined field names' do
    ActionKitFields::ACTIONKIT_FIELDS_WHITELIST.each do |name|
      it "is valid with #{name}" do
        expect(subject.new(name: name)).to be_valid
      end
    end
  end

  context 'with invalid characters' do
    ['foo bar', 'Foo_bar', 'foo-bar', 'action_foo-bar'].each do |name|
      it "is invalid with #{name}" do
        expect(subject.new(name: name)).to_not be_valid
      end
    end
  end

  context 'with unknown field names' do
    %w[blah raa kangaroo foo_action foo_user action_ user_].each do |name|
      it "is invalid with #{name}" do
        expect(subject.new(name: name)).to_not be_valid
      end
    end

    context 'with action_ prefix' do
      %w[foo bar exam_aple].each do |name|
        unknown_with_prefix = "action_#{name}"

        it "is valid with #{unknown_with_prefix}" do
          expect(subject.new(name: unknown_with_prefix)).to be_valid
        end
      end
    end
  end
end
