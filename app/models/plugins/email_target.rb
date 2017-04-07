# frozen_string_literal: true
# == Schema Information
#
# Table name: plugins_email_targets
#
#  id                 :integer          not null, primary key
#  ref                :string
#  page_id            :integer
#  active             :boolean          default(FALSE)
#  email_from         :string
#  email_subject      :string
#  email_body_b       :text
#  created_at         :datetime
#  updated_at         :datetime
#  test_email_address :string
#  email_body_a       :text
#  email_body_c       :text
#

class Plugins::EmailTarget < ActiveRecord::Base
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
      page: page.slug,
      email_subject: email_subject,
      email_header: email_body_a,
      email_body: email_body_b,
      email_footer: email_body_c
    }
  end
end
