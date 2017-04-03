Settings.liquid_templating_source = 'file'
# frozen_string_literal: true
# The <tt>LiquidFileSystem</tt> class is used by +Liquid+ for
# retrieving partial content.
#
# Partials are rendered within template content using the +include+ tag:
#
#   {% include 'post' %}
#
# The above tag is equivalent to calling:
#
#   LiquidFileSystem.read_template_file('post')
#
# <tt>LiquidFileSystem</tt> will query the <tt>LiquidPartial</tt> model
# for a record with a matching +title+. If this returns nil, the
# filesystem is checked for a file with a matching name.
# Partial filenames, like Rails partials, are preceeded with a +_+,
# and end with +.liquid'.
#
#   _post.liquid
#
# When developing a new partial, you can set <tt>Settings.liquid_templating_source</tt>
# to 'file'. This will force the class to always read content from file.
class LiquidFileSystem
  class << self
    # Returns an array of matching files.
    #
    # ==== Options
    #
    # * +title+
    #
    def partials(title)
      filename = title.to_s.parameterize.underscore
      internal_files = [
        "#{Rails.root}/app/views/plugins/**/_#{filename}.liquid",
        "#{Rails.root}/app/liquid/views/partials/_#{filename}.liquid"
      ]
      external_files = external_dirs.map { |path| File.join(path, 'partials', "_#{filename}.liquid") }
      Dir.glob(internal_files + external_files)
    end

    def read_template_file(title)
      #return read(title) unless Settings.liquid_templating_source == 'file'
      read_from_file(title)
    end

    private

    def read(title)

      read_from_file(title) || read_from_store(title) || "Partial #{title} was not found"
    end

    def read_from_store(title)
      LiquidPartial.find_by(title: title).try(:content)
    end

    def read_from_file(title)
      return nil if partials(title).empty?
      puts "READ FROM FILE #{title}"
      File.read(partials(title).first)
    end

    def external_dirs
      return [] unless Settings.external_asset_paths.present? && Settings.external_liquid_path.present?
      Settings.external_asset_paths.split(':').map { |path| File.join(path, Settings.external_liquid_path) }
    end
  end
end
