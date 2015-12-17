class Plugins::Petition < ActiveRecord::Base
  include Plugins::HasForm

  belongs_to :page
  validates :cta, presence: true, allow_blank: false

  DEFAULTS = { cta: 'Sign the Petition' }

  def liquid_data(supplemental_data={})
    attributes.merge(form_liquid_data(supplemental_data))
  end
end
