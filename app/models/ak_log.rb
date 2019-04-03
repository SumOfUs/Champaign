# frozen_string_literal: true

# == Schema Information
#
# Table name: ak_logs
#
#  id              :integer          not null, primary key
#  request_body    :text
#  response_body   :text
#  response_status :string
#  resource        :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class AkLog < ApplicationRecord
end
