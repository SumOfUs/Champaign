class LiquidFileSystem
  class << self
    def partials(title)
      Dir.glob(["#{Rails.root}/app/views/plugins/**/_#{title}.liquid", "#{Rails.root}/app/views_liquid/**/_#{title}.liquid"])
    end

    def read_template_file(title)
      if ENV['LIQUID_TEMPLATING_SOURCE'] == 'file'
        return read_from_file(title)
      else
        return read(title)
      end
    end

    private

    def read(title)
      read_from_store(title) || read_from_file(title) || "Partial #{title} was not found"
    end

    def read_from_store(title)
      LiquidPartial.find_by(title: title).try(:content)
    end

    def read_from_file(title)
      return nil if LiquidFileSystem.partials(title).empty?
      File.read(LiquidFileSystem.partials(title).try(:first))
    end
  end
end

