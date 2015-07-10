class Template < ActiveRecord::Base
  has_paper_trail

  validates_uniqueness_of :template_name

  has_many :widgets, as: :page, dependent: :destroy
  accepts_nested_attributes_for :widgets

  scope :active, -> { where(active: true) }
end
