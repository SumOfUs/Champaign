# frozen_string_literal: true
# == Schema Information
#
# Table name: plugins_texts
#
#  id         :integer          not null, primary key
#  content    :text
#  ref        :string
#  page_id    :integer
#  active     :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

class Plugins::Text < ApplicationRecord
  belongs_to :page, touch: true

  DEFAULTS = {}.freeze

  def liquid_data(_supplemental_data = {})
    attributes
  end

  def name
    self.class.name.demodulize
  end
end
