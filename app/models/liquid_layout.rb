class LiquidLayout < ActiveRecord::Base
  has_many :campaign_pages
  validates :title, presence: true, allow_blank: false
  validates :content, presence: true, allow_blank: false
  validate :real_partials

  def partial_names
    template = Liquid::Template.parse(content)
    includes = template.root.nodelist.select{|node| node.class == Liquid::Include}
    return includes.map{ |li| li.instance_values['template_name'].gsub(/\A["']|["']\Z/, '') }
  end

  def real_partials
    partial_names.each do |name|
      partial = LiquidPartial.find_by(title: name)
      errors.add :content, "includes unknown partial '#{name}'" if partial.nil?
    end
  end

end
