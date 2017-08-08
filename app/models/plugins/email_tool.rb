# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_email_tools
#
#  id                 :integer          not null, primary key
#  ref                :string
#  page_id            :integer
#  active             :boolean          default("false")
#  email_from         :string
#  email_subjects     :string           default("{}"), is an Array
#  email_body         :text
#  email_body_header  :text
#  email_body_footer  :text
#  test_email_address :string
#  targets            :json             default("{}"), is an Array
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Plugins::EmailTool < ApplicationRecord
  DEFAULTS = {}.freeze
  include HasTargets
  set_target_class ::EmailTool::Target

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
