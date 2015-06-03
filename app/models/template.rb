class Template < ActiveRecord::Base
  has_paper_trail

  validates_uniqueness_of :template_name

  has_and_belongs_to_many :widget_types
  accepts_nested_attributes_for :widget_types
end
