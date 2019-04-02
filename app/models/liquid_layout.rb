# frozen_string_literal: true

# == Schema Information
#
# Table name: liquid_layouts
#
#  id                          :integer          not null, primary key
#  content                     :text
#  description                 :text
#  experimental                :boolean          default(FALSE), not null
#  post_action_layout          :boolean
#  primary_layout              :boolean
#  title                       :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  default_follow_up_layout_id :integer
#

class LiquidLayout < ApplicationRecord
  include HasLiquidPartials
  has_paper_trail

  has_many :pages
  belongs_to :default_follow_up_layout, class_name: 'LiquidLayout'

  validates :title, presence: true, allow_blank: false
  validates :content, presence: true, allow_blank: false
  validates :experimental, inclusion: { in: [true, false] }

  scope :campaigner_friendly, -> { where(experimental: false) }

  def plugin_refs
    # pass depth of -1 to allow layouts one more level of nesting than partials
    super(depth: -1)
  end
end
