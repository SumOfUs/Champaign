# == Schema Information
#
# Table name: registered_target_endpoints
#
#  id          :bigint(8)        not null, primary key
#  description :text
#  name        :string
#  url         :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe RegisteredTargetEndpoint, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
