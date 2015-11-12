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
# When developing a new partial, you can set <tt>ENV['LIQUID_TEMPLATING_SOURCE']</tt>
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
      Dir.glob([
        "#{Rails.root}/app/views/plugins/**/_#{title}.liquid",
        "#{Rails.root}/app/views_liquid/**/_#{title}.liquid"
      ])
    end

    def read_template_file(title)
      if Settings.liquid_templating_source == 'file'
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
      return nil if self.partials(title).empty?
      File.read( self.partials(title).first )
    end
  end
end

