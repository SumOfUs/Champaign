# Image widget concern - contains the logic for getting contents for the image widget out of the form
require 'active_support/concern'

module ImageWidget
  
  extend ActiveSupport::Concern
  include ImageCropper

  def self.handle(widget_data, params)
    # Save image to file named after the slug, with a UUID appended to it, in app/assets/images.
    # All images are saved as jpg in ImageCropper.save
    filename = add_uuid_to_filename(params[:campaign_page][:slug]) + '.jpg'

    # if image upload field has been specified
    if widget_data.key? 'image_upload'
      image = widget_data['image_upload']
    # else, if we want the image from a URL
    else
      image = URI.parse(widget_data['image_url'])
    end

    # handle image processing and save image
    ImageCropper.set_params(params, image)
    ImageCropper.crop
    ImageCropper.resize
    ImageCropper.save(filename)

    # The image's location /filename in the widget content
    widget_data['image_url'] = filename
  end
end
