module LiquidMarkupSeeder
  extend self

  def seed
    files.each do |path|
      title, klass = title_and_class(path)
      content = read(path)

      memo = klass.constantize.find_or_create_by(title: title) do |view|
        view.content = content
      end
    end
  end

  def read(file_path)
    File.read(file_path)
  end

  def files
    Dir.glob(
      [
       "#{Rails.root}/app/views/plugins/**/*.liquid",
       "#{Rails.root}/app/liquid/views/**/*.liquid"
      ]
    )
  end

  def title_and_class(file)
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

