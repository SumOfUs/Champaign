# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_email_pensions
#
#  id                    :integer          not null, primary key
#  ref                   :string
#  page_id               :integer
#  active                :boolean          default("false")
#  email_subjects        :string           default("{}"), is an Array
#  email_body            :text
#  created_at            :datetime
#  updated_at            :datetime
#  test_email_address    :string
#  email_body_header     :text
#  email_body_footer     :text
#  use_member_email      :boolean          default("false")
#  from_email_address_id :integer
#

class Plugins::EmailPension < ApplicationRecord
  DEFAULTS = {}.freeze

  belongs_to :page, touch: true
  belongs_to :form
  belongs_to :from_email_address, class_name: 'RegisteredEmailAddress'
  belongs_to :registered_target_endpoint

  def name
    self.class.name.demodulize
  end

  def liquid_data(_supplemental_data = {})
    {
      page_id: page_id,
      plugin_id: id,
      locale: page.language_code,
      active: active,
      email_subject: email_subjects.sample,
      email_header: email_body_header,
      email_body: email_body,
      email_footer: email_body_footer,
      target_endpoint: registered_target_endpoint.try(:url)
    }
  end
end
