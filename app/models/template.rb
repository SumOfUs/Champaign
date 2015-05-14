class Template < ActiveRecord::Base
  validates_uniqueness_of :template_name

  has_and_belongs_to_many :widget_types
  has_many :campaign_pages
  accepts_nested_attributes_for :widget_types
end
