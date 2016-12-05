# frozen_string_literal: true
require 'paperclip/matchers'

RSpec.configure do |config|
  config.include Paperclip::Shoulda::Matchers
end

# skip ImageMagick for test suite
# from http://grease-your-suite.herokuapp.com/
# and https://gist.github.com/ngauthier/406460
module Paperclip
  class Geometry
    def self.from_file(_file)
      parse('100x100')
    end
  end
  class Thumbnail
    def make
      src = Rails.root.join('spec', 'fixtures', 'test-image.gif')
      dst = Tempfile.new([@basename, 'gif'].compact.join('.'))
      dst.binmode
      FileUtils.cp(src, dst.path)
      dst
    end
  end
end
