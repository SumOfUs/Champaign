require 'rails_helper'
require_relative 'shared_examples'

describe Share::EmailsController do
  include_examples "shares", Share::Email, 'email'

  let(:share){ instance_double('Share::Email') }
  let(:params){ { subject: "Foo", body: 'Bar' } }
  let(:new_defaults) { { subject: 'Foo', body: 'Bar {LINK}' }}
end

