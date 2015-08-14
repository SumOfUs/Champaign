class LiquidFileSystem
  def read_template_file(title)
    view = LiquidPartial.find_by(title: title)

    if view
      return view.content
    else
      partials = Dir.glob("#{Rails.root}/app/views/plugins/**/_#{title}.liquid")
      if partials.any?
        File.read partials.first
      else
        "Partial #{title} was not found"
      end
    end
  end
end
