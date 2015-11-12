class Tag < ActiveRecord::Base
  validates :name, :actionkit_uri, presence: true, uniqueness: true

  has_many :pages_tags, dependent: :destroy
  has_many :pages, through: :pages_tags

end

