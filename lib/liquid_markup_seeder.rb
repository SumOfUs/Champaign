module LiquidMarkupSeeder
  extend self

  def seed
    files.each do |path|
      title, model = meta(path)
      content = read(path)
      model.constantize.find_or_initialize_by(title: title).
        update(content: content)
    end
  end

  def read(file_path)
    File.read(file_path)
  end

  def files
    Dir.glob(["#{Rails.root}/app/views/plugins/**/*.liquid", "#{Rails.root}/app/views_liquid/**/*.liquid", "#{Rails.root}/app/views/layouts/*.liquid"])
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

