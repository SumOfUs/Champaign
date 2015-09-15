class LiquidFileSystem
  class << self
    def partials(title)
      @partials ||= Dir.glob(["#{Rails.root}/app/views/plugins/**/_#{title}.liquid", "#{Rails.root}/app/views_liquid/**/_#{title}.liquid"])
    end

    def read_template_file(title)
      view = LiquidPartial.find_by(title: title)
      if view
        return view.content
      else
        if LiquidFileSystem.partials(title).any?
          File.read LiquidFileSystem.partials(title).first
        else
          "Partial #{title} was not found"
        end
      end
    end
  end
end
