# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_texts
#
#  id         :integer          not null, primary key
#  active     :boolean          default(FALSE)
#  content    :text
#  ref        :string
#  created_at :datetime
#  updated_at :datetime
#  page_id    :integer
#
# Indexes
#
#  index_plugins_texts_on_page_id  (page_id)
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
