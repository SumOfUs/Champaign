# Image cropper - used on images when posting and updating campaigns and donations
require 'open-uri'
require 'rmagick'

class ImageWidgetService

  def initialize(params)

    widget_data = params[:widgets][:image]

    # if image upload field contains data
    if widget_data.key? 'image_upload'
      image = widget_data['image_upload']
    # else, if we want the image from a URL
    else
      image = URI.parse(widget_data['image_url'])
    end

    @x = widget_data['image_x'].to_f
    @y = widget_data['image_y'].to_f
    @width = widget_data['image_width'].to_f
    @height = widget_data['image_height'].to_f
    @image = Magick::Image.from_blob(open(image).read).first
    # Save image to file named after the slug, with a UUID appended to it, in app/assets/images.
    # All images get converted to jpg.
    @filename = 'app/assets/images/' + params[:campaign_page][:title].parameterize + '.jpg'

  end

  def crop
    # crop image according to crop parameters
    @image.crop!(@x * @image.columns, @y * @image.rows, @width * @image.columns, @height * @image.rows, true)
  end

  def optimise
    @image.change_geometry!('1120x800') { |cols, rows, img|
      img.resize!(cols, rows)
    }
    # Set image to jpeg, remove comments and profile form the image
    @image.format = 'JPEG'
    @image.strip!
  end

  def save(filename)
    # Compress image and write it to a file named after the petition slug
    @image.write(filename) { self.quality = 90 }
    # Remove imagemagick reference
    @image = nil
  end

  def process
    self.crop
    self.optimise
    self.save(@filename)
  end
end
