# frozen_string_literal: true
# The <tt>ActionKitFields</tt> class is a Rails <tt>ActiveModel::Validator<tt> class
# for validating a model's +name+ field against ActionKits +action+ and +user+
# tables.
#
# Valid field names must be whitelisted ( see <tt>ACTIONKIT_FIELDS_WHITELIST</tt> ),
# or they must be prefixed with +action_+. All field names must not
# have spaces or dashes.
#
# See also https://act.sumofus.org/docs/manual/api/rest/actionprocessing.html for detailed documentation
# on ActionKit's action processing.
#
# ==== Valid Field Names
#
#   address1
#   state
#   action_bar
#   action_foo_bar
#   user_foo
#
# ==== Invalid Field Names
#
#   address_action
#   foo-bar
#   foobar
#   action_foo bar
#

class ActionKitFields < ActiveModel::Validator
  VALID_CHARS_RE = /^[0-9a-z_]+$/

  # +VALID_PREFIX_RE+ matches for allowed prefixes for custom fields for ActionKit actions.
  #
  # A custom field must must have the necessary prefix for it to
  # be considered valid by ActionKit
  #
  # For more information, see ActionKit's documentation on action processing:
  #
  #   https://act.sumofus.org/docs/manual/api/rest/actionprocessing.html#custom-user-fields
  #   https://act.sumofus.org/docs/manual/api/rest/actionprocessing.html#custom-action-fields
  #
  VALID_PREFIX_RE = /^(action)\_[0-9a-z_]+/

  ACTIONKIT_FIELDS_WHITELIST = %w(
    address1
    address2
    city
    country
    email
    first_name
    home_phone
    last_name
    middle_name
    mobile_phone
    name
    phone
    plus4
    postal
    prefix
    region
    state
    suffix
    zip
  ).freeze

  CUSTOM_PREFIXES = %w(
    action_
  ).freeze

  def validate(record)
    @name = record.name
    unless has_valid_form
      record.errors[:name] << "'#{record.name}' is not a permitted ActionKit name."
    end
    unless has_valid_characters
      record.errors[:name] << "'#{record.name}' may only contain numbers, underscores, and lowercase letters."
    end
  end

  def self.is_predefined_by_ak(name)
    ACTIONKIT_FIELDS_WHITELIST.include?(name.to_s)
  end

  private

  # Does the name match an existing ActionKit field name, else
  # does it have a valid prefix ( +action_+, or +user_+ ).
  def has_valid_form
    is_predefined_by_ak || has_valid_prefix
  end

  def has_valid_characters
    @name =~ VALID_CHARS_RE
  end

  def is_predefined_by_ak
    ACTIONKIT_FIELDS_WHITELIST.include?(@name)
  end

  def has_valid_prefix
    @name =~ VALID_PREFIX_RE
  end
end
