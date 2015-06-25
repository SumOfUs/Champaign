# required for reading/writing images for the image widget. Should be refactored to a separate file, together with 
# the image processing logic.
class CampaignPagesController < ApplicationController

  include ImageCropper

  before_action :authenticate_user!, except: [:show]
  before_action :get_campaign_page, only: [:show, :edit, :update, :destroy]

  def get_campaign_page
    @campaign_page = CampaignPage.find(params[:id])
  end

  def index
    if params['disabled']
      @campaign_pages = CampaignPage.where active: false
      @title = 'All Disabled Campaign Pages'
      @disabled = true
    else
      @campaign_pages = CampaignPage.where(active: true).order(created_at: :desc).limit(25)
      @title = 'All Active Campaign Pages'
      @featured_pages = @campaign_pages.where featured: true
      @disabled = false
    end
  end

  def new
    @campaign_page = CampaignPage.new
    @templates = Template.where active: true
    @campaigns = Campaign.where active: true
    # Sets @campaign, which is defined if a new campaign page is created through a link from a campaign page.
    # In this case, that campaign is set as a default in the dropdown list.
    @campaign = params[:campaign]
    # Load the first active template as a default.
    @template = @templates.first 
  end

  def create
    permitted_params = CampaignPageParameters.new(params).permit
    permitted_params[:slug] = permitted_params[:title].parameterize
    permitted_params[:active] = true
    permitted_params[:featured] = false
    campaign = Campaign.find(permitted_params[:campaign_id])
    # creates a campaign page associated to the campaign specified in the form.
    page = campaign.campaign_page.create! permitted_params.except(:campaign)
    # Collects all widgets that were associated with the campaign page that was created,
    # then loops through them to store them as entries in the campaign_pages_widgets 
    # table linked to the campaign page they belong to. Their content is pulled from 
    # the data entered to the forms for the widgets, and their page display order is assigned
    # from the order in which they were laid out in the creation form.
    widgets = params[:widgets]
    i = 0
    widgets.each do |widget_type_name, widget_data|
      # widget type id is contained in a field called widget_type:
      widget_type_id = widget_data.delete :widget_type

      case widget_type_name 
        # We have some placeholder data for checkboxes and textareas if we are using a
        # petition form. We need to remove those or we'll end up with phantom elements in our
        # form.
        when 'petition'
          if widget_data.key?('checkboxes') and widget_data['checkboxes'].key?('{cb_number}')
            widget_data['checkboxes'].delete('{cb_number}')
          end
          if widget_data.key?('textarea') and widget_data['textarea'].key?('placeholder')
            widget_data['textarea'].delete('placeholder')
          end

        when 'image'
          # if image upload field has been specified
          if widget_data.key? 'image_upload'
            image = widget_data['image_upload']
          # else, if we want the image from a URL
          else
            image = URI.parse(widget_data['image_url'])
          end
            # Save image to file named after the slug, with a UUID appended to it, in app/assets/images.
            # All images are saved as jpg in ImageCropper.save
            filename = add_uuid_to_filename(permitted_params[:slug]) + '.jpg'

            # handle image processing and save image
            ImageCropper.set_params(params, image)
            ImageCropper.crop
            ImageCropper.resize
            ImageCropper.save(filename)

            # The image's location /filename in the widget content
            widget_data['image_url'] = filename
       end
      
      page.campaign_pages_widgets.create!(widget_type_id: widget_type_id,
                                         content: widget_data,
                                         page_display_order: i)
      i += 1
    end
    redirect_to page
  end

  def show
    if @campaign_page.active == false
      redirect_to :campaign_pages, notice: "The page you wanted to view has been deactivated."
    end  
  end

  def edit
  end

  def update
    @widgets = @campaign_page.campaign_pages_widgets

    permitted_params = CampaignPageParameters.new(params).permit
    permitted_params[:slug] = permitted_params[:title].parameterize
    permitted_params[:campaign_pages_widgets_attributes] = []
    params[:widgets].each do |widget_type_name, widget_data|
      # widget type id is contained in a field called widget_type:
      widget_type_id = widget_data.delete :widget_type
      # This will break if there will be two widgets of the same type for the page. If we enable having two of the same widget type per page,
      # page display order will need to be considered as well for fetching the correct id of the widget.
      widget = @widgets.find_by(widget_type_id: widget_type_id)
      permitted_params[:campaign_pages_widgets_attributes].push({
        id: widget.id,
        widget_type_id: widget_type_id,
        content: widget_data,
        page_display_order: widget.page_display_order})
    end

    # We pass the parameters through the strong parameter class first. That transforms it from a hash to ActionController::Parameters. 
    # Only after that, we manipulate it by adding slug and title, and in my case, by adding a key called :campaign_pages_widgets_attributes, 
    # which is required for the nested parameters. Despite of setting up the strong parameters for the dependent object (campaign_pages_widgets),
    # Strong params don't pass those values through. My current work around is to just pass permitted_params.to_hash instead, and the pages update fine.
    @campaign_page.update! permitted_params.to_hash
    redirect_to @campaign_page
  end

  def sign
    # Nothing here for the moment
    render json: {success: true}, layout: false
  end
end
