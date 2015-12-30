module LiquidMarkupSeeder
  extend self

  def seed
    sort_by_partial_count(partials).each{ |path| create(path) }
    layouts.each { |path| create(path) }
  end

  def read(file_path)
    File.read(file_path)
  end

  def create(path)
    title, klass = title_and_class(path)
    puts "creating #{klass} called #{title} from path #{path}"

    view = klass.constantize.find_or_create_by(title: title)
    view.content = read(path)
    set_metadata_fields(view)
    saved = view.save
    puts "Failed to save: #{view.errors.full_messages}" unless saved
  end

  def partials
    Dir.glob(
      [
       "#{Rails.root}/app/views/plugins/**/_*.liquid",
       "#{Rails.root}/app/liquid/views/partials/_*.liquid"
      ]
    )
  end

  def layouts
    Dir.glob(["#{Rails.root}/app/liquid/views/layouts/*.liquid"])
  end

  def title_and_class(file)
    [parse_name(file), klass(file)]
  end

  def parse_name(file)
    file.split('/').
      last.
      gsub(/^\_|\.liquid$/, '').
      titleize
  end

  def klass(file)
    file =~ /\_\w+\.liquid$/ ? 'LiquidPartial' : 'LiquidLayout'
  end

  def sort_by_partial_count(paths)
    paths.sort_by do |path|
      LiquidTagFinder.new(read(path)).partial_names.size
    end
  end

  def set_metadata_fields(view)
    return unless view.is_a? LiquidLayout
    ltf = LiquidTagFinder.new(view.content)
    view.experimental = ltf.experimental?
    view.description = ltf.description
  end
end

