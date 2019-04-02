# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_petitions
#
#  id          :integer          not null, primary key
#  active      :boolean          default(FALSE)
#  cta         :string
#  description :text
#  ref         :string
#  target      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  form_id     :integer
#  page_id     :integer
#
# Indexes
#
#  index_plugins_petitions_on_form_id  (form_id)
#  index_plugins_petitions_on_page_id  (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (form_id => forms.id)
#  fk_rails_...  (page_id => pages.id)
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
