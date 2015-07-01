# Image cropper - used on images when posting and updating campaigns and donations
require 'active_support/concern'
require 'open-uri'
require 'rmagick'

module ImageCropper
  extend ActiveSupport::Concern

  def self.set_params(params, image)
    @x = params['image_x'].to_f
    @y = params['image_y'].to_f
    @width = params['image_width'].to_f
    @height = params['image_height'].to_f
    @image = Magick::Image.from_blob(open(image).read).first
  end

  def self.crop
    # crop image according to crop parameters
    @image.crop!(@x * @image.columns, @y * @image.rows, @width * @image.columns, @height * @image.rows, true)
  end

  def self.resize
    @image.change_geometry!('1120x800') { |cols, rows, img|
      img.resize!(cols, rows)
    }
  end

  def self.save(filename)
    # Set image to jpeg, remove comments and profile form the image
    @image.format = 'JPEG'
    @image.strip!
    # Compress image and write it to a file named after the petition slug
    @image.write('app/assets/images/'+filename) { self.quality = 90 }
    # Remove imagemagick reference to prevent memory leakage
    @image = nil
  end

end
