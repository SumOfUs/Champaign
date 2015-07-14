# Image widget concern - contains the logic for getting contents for the image widget out of the form
require 'active_support/concern'

module ImageWidget
  
  extend ActiveSupport::Concern
  include ImageCropper

  def self.handle(widget_data, params)
    # Save image to file named after the slug, with a UUID appended to it, in app/assets/images.
    # All images are saved as jpg in ImageCropper.save
    filename = add_uuid_to_filename(params[:campaign_page][:title].parameterize) + '.jpg'

    
    # if image upload field has been specified, use file upload
    if widget_data.key? 'image_upload'
      puts 'upload the image'
      image = widget_data['image_upload']
    # else, look at image URL:
    # if file already exists in app/assets/images, use it
    elsif File.exist? "app/assets/images/#{widget_data['image_url']}"
      image = "app/assets/images/#{widget_data['image_url']}"
      # if the image name already contains the UUID (if we're editing a page),
      # keep the original file name
      if image_has_uuid(widget_data['image_url'])
        filename = widget_data['image_url']
      end
    # else, if the image url specifies an external image
    elsif image_is_external_url(widget_data['image_url'])
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
