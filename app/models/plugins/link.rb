class Plugins::Link < ActiveRecord::Base
  belongs_to :linkset

  DEFAULTS = {}

  validates :url, :title, presence: true, allow_blank: false
  validates_associated :linkset

end
