# frozen_string_literal: true
class LiquidLayout < ActiveRecord::Base
  include HasLiquidPartials
  has_paper_trail

  has_many :pages
  belongs_to :default_follow_up_layout, class_name: LiquidLayout

  validates :title, presence: true, allow_blank: false
  validates :content, presence: true, allow_blank: false
  validates :experimental, inclusion: { in: [true, false] }

  scope :campaigner_friendly, -> { where(experimental: false) }

  def plugin_refs
    # pass depth of -1 to allow layouts one more level of nesting than partials
    super(depth: -1)
  end
end
