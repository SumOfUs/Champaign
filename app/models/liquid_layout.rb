class LiquidLayout < ActiveRecord::Base
  has_many :campaign_pages
  validates :title, presence: true, allow_blank: false
  validates :content, presence: true, allow_blank: false
  validate :real_partials

  def partial_names
    LiquidTagFinder.new(content).partial_names
  end

  def partial_refs
    LiquidTagFinder.new(content).partial_refs
  end

  def real_partials
    partial_names.each do |name|
      partial = LiquidPartial.find_by(title: name)
      errors.add :content, "includes unknown partial '#{name}'" if partial.nil?
    end
  end

end
