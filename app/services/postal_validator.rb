# frozen_string_literal: true
class PostalValidator
  # These regular expressions graciously provided by David Gil in his project located at https://github.com/dgilperez/validates_zipcode/blob/master/lib/validates_zipcode/cldr_regex_collection.rb
  # After testing on a live system, we discovered that this level of validation was detrimental to our data capture,
  # and our data analysts didn't need the added validity anyway. As a result, we've disabled everything but the US validation
  # due to the fact that ActionKit validates only US Zip Codes and we wish to avoid approving data the back-end database
  # cannot process.
  ZIPCODES_REGEX = {
    US: /\A\d{5}([ \-]\d{4})?\z/
  }.freeze

  def self.valid?(postal_code, country_code: nil)
    return true unless ZIPCODES_REGEX.key? country_code
    !(ZIPCODES_REGEX[country_code] =~ postal_code).nil?
  end
end
