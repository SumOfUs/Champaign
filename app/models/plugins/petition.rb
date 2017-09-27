# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_petitions
#
#  id          :integer          not null, primary key
#  page_id     :integer
#  active      :boolean          default("false")
#  form_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#  ref         :string
#  target      :string
#  cta         :string
#

class Plugins::Petition < ApplicationRecord
  include Plugins::HasForm

  belongs_to :page, touch: true

  validates :cta, presence: true, allow_blank: false

  DEFAULTS = { cta: 'petition.sign_it' }.freeze

  def liquid_data(supplemental_data = {})
    attributes.merge(form_liquid_data(supplemental_data))
  end
end
