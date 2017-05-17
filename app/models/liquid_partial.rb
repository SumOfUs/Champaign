# frozen_string_literal: true
# == Schema Information
#
# Table name: liquid_partials
#
#  id         :integer          not null, primary key
#  title      :string
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class LiquidPartial < ApplicationRecord
  include HasLiquidPartials
  has_paper_trail

  validates :title,   presence: true, allow_blank: false
  validates :content, presence: true, allow_blank: false

  validate :one_plugin

  def plugin_name
    LiquidTagFinder.new(content).plugin_names[0]
  end

  # Filters array of partial names to those absent from the database.
  #
  def self.missing_partials(names)
    names.reject { |name| LiquidPartial.exists?(title: name) }
  end

  private

  def one_plugin
    plugin_names = LiquidTagFinder.new(content).plugin_names
    return unless plugin_names.size > 1

    errors.add(:content, "can only reference one partial, but found #{plugin_names.join(',')}")
  end
end
