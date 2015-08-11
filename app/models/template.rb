class Template < ActiveRecord::Base
  has_paper_trail
  validates_uniqueness_of :template_name

  scope :active, -> { where(active: true) }
end
