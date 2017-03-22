# frozen_string_literal: true

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
      email_body: email_body
    }
  end
end
