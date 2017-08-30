# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_email_pensions
#
#  id                 :integer          not null, primary key
#  ref                :string
#  page_id            :integer
#  active             :boolean          default("false")
#  email_from         :string
#  email_subjects     :string           default("{}"), is an Array
#  email_body         :text
#  created_at         :datetime
#  updated_at         :datetime
#  test_email_address :string
#  email_body_header  :text
#  email_body_footer  :text
#

class Plugins::EmailPension < ApplicationRecord
  DEFAULTS = {}.freeze

  belongs_to :page, touch: true
  belongs_to :form

  def name
    self.class.name.demodulize
  end

  def liquid_data(_supplemental_data = {})
    {
      page_id: page_id,
      locale: page.language_code,
      active: active,
      email_subject: email_subjects.sample,
      email_header: email_body_header,
      email_body: email_body,
      email_footer: email_body_footer
    }
  end
end
