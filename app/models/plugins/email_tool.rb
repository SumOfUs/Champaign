# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_email_tools
#
#  id                 :integer          not null, primary key
#  ref                :string
#  page_id            :integer
#  active             :boolean          default(FALSE)
#  email_from         :string
#  email_subjects     :string           default([]), is an Array
#  email_body_b       :text
#  created_at         :datetime
#  updated_at         :datetime
#  test_email_address :string
#  email_body_a       :text
#  email_body_c       :text
#

class Plugins::EmailTool < ApplicationRecord
  DEFAULTS = {}.freeze
  include HasTargets
  use_tool_module ::EmailTool

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
      page: page.slug,
      email_subject: email_subjects.sample,
      email_header: email_body_header,
      email_footer: email_body_footer,
      email_body: email_body
    }
  end
end
