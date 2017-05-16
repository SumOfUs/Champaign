# frozen_string_literal: true

require 'rails_helper'

describe ActionKit::Helper do
  describe '#check_petition_name_is_available' do
    it 'returns true when name is available' do
      VCR.use_cassette('actionkit_helper_petition_name_check_true') do
        expect(
          ActionKit::Helper.check_petition_name_is_available('i-dont-exist-anywhere-im-a-total-snowflake')
        ).to be true
      end
    end

    it "returns false when name isn't available" do
      VCR.use_cassette('actionkit_helper_petition_name_check_false') do
        expect(
          ActionKit::Helper.check_petition_name_is_available('foo-bar')
        ).to be false
      end
    end
  end
end
