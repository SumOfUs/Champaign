class LiquidLayout < ActiveRecord::Base
  has_many :campaign_pages
  validates :title, presence: true, allow_blank: false
  validates :content, presence: true, allow_blank: false
  validate :real_partials

  def partial_names
    tag_finder = LiquidTagFinder.new(content)
    return tag_finder.partial_names
  end

  def real_partials
    partial_names.each do |name|
      partial = LiquidPartial.find_by(title: name)
      errors.add :content, "includes unknown partial '#{name}'" if partial.nil?
    end
  end

end
