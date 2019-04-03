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

require 'rails_helper'

describe AkLog do
  let(:aklog) { create :ak_log }
  subject { aklog }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to :request_body }
  it { is_expected.to respond_to :response_body }
  it { is_expected.to respond_to :response_status }
  it { is_expected.to respond_to :resource }
end
