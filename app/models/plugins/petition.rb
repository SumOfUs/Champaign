# frozen_string_literal: true
class Plugins::Petition < ActiveRecord::Base
  include Plugins::HasForm

  belongs_to :page, touch: true

  validates :cta, presence: true, allow_blank: false

  DEFAULTS = { cta: 'petition.sign_it' }.freeze

  def liquid_data(supplemental_data = {})
    attributes.merge(form_liquid_data(supplemental_data))
  end
end
