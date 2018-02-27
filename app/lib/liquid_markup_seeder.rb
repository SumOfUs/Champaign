# frozen_string_literal: true
# rubocop:disable all

module LiquidMarkupSeeder
  extend self

  def seed(quiet: false)
    partials.each { |path| init_partial(path) }
    partials.each { |path| create(path, quiet) }
    layouts.each { |path| create(path, quiet) }
  end

  def read(file_path)
    File.read(file_path)
  end

  def create(path, quiet)
    title, klass = title_and_class(path)
    puts "creating #{klass} called #{title} from path #{path}" unless quiet

    view = klass.constantize.find_or_create_by(title: title)
    view.content = read(path)
    set_metadata_fields(view)
    saved = view.save
    puts "Failed to save: #{view.errors.full_messages}" unless saved || quiet
  end

  def init_partial(path)
    title, klass = title_and_class(path)
    existing = klass.constantize.find_by(title: title)
    klass.constantize.create(title: title, content: 'temp') if existing.blank?
  end

  def titles
    layouts.map { |file| parse_name(file) }
  end

  def partials
    internal_files = [
      "#{Rails.root}/app/views/plugins/**/_*.liquid",
      "#{Rails.root}/app/liquid/views/partials/_*.liquid"
    ]
    external_files = external_dirs.map { |path| File.join(path, 'partials', '_*.liquid') }
    Dir.glob(internal_files + external_files)
  end

  def layouts
    internal_files = ["#{Rails.root}/app/liquid/views/layouts/*.liquid"]
    external_files = external_dirs.map { |path| File.join(path, 'layouts', '*.liquid') }
    Dir.glob(internal_files + external_files)
  end

  def title_and_class(file)
    [parse_name(file), klass(file)]
  end

  def parse_name(file)
    file
      .split('/')
      .last
      .gsub(/^\_|\.liquid$/, '')
      .titleize
  end

  def klass(file)
    file.match?(/\_\w+\.liquid$/) ? 'LiquidPartial' : 'LiquidLayout'
  end

  def set_metadata_fields(view)
    return unless view.is_a? LiquidLayout
    ltf = LiquidTagFinder.new(view.content)
    view.experimental = ltf.experimental?
    view.primary_layout = ltf.primary_layout?
    view.post_action_layout = ltf.post_action_layout?
    view.description = ltf.description
  end

  def external_dirs
    return [] unless Settings.external_assets_path.present? && Settings.external_liquid_path.present?
    Settings.external_assets_path.split(':').map { |path| File.join(path, Settings.external_liquid_path) }
  end
end
