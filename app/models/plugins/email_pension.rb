# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_email_pensions
#
#  id                            :integer          not null, primary key
#  active                        :boolean          default(FALSE)
#  email_body                    :text
#  email_body_footer             :text
#  email_body_header             :text
#  email_subjects                :string           default([]), is an Array
#  ref                           :string
#  test_email_address            :string
#  use_member_email              :boolean          default(FALSE)
#  created_at                    :datetime
#  updated_at                    :datetime
#  from_email_address_id         :integer
#  page_id                       :integer
#  registered_target_endpoint_id :integer
#
# Indexes
#
#  index_plugins_email_pensions_on_page_id  (page_id)
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
