module LiquidMarkupSeeder
  extend self

  def seed
    files.each do |path|
      title, model = meta(path)
      content = read(path)
      existing = model.constantize.find_by_title(title)

      if existing
        existing.update content: content
      else
        model.constantize.create( title: title, content: content)
      end
    end
  end

  def read(file_path)
    File.read(file_path)
  end

  def files
    Dir.glob("#{Rails.root}/app/views/plugins/**/*.liquid")
  end

  def meta(file)
    [parse_name(file), klass(file)]
  end

  def parse_name(file)
    file.split('/').
      last.
      gsub(/^\_|\.liquid$/, '')
  end

  def klass(file)
    file =~ /\_\w+\.liquid$/ ? 'LiquidPartial' : 'LiquidLayout'
  end
end
