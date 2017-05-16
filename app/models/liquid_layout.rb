# frozen_string_literal: true
# == Schema Information
#
# Table name: liquid_layouts
#
#  id                          :integer          not null, primary key
#  title                       :string
#  content                     :text
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  description                 :text
#  experimental                :boolean          default(FALSE), not null
#  default_follow_up_layout_id :integer
#  primary_layout              :boolean
#  post_action_layout          :boolean
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
