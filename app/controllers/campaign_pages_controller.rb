class CampaignPagesController < ApplicationController

  def new
    @campaign_page = CampaignPage.new
    @templates = Template.where active: true
    # @widget_types = template.widget_types
  end

  def create

    permitted_params = CampaignPageParameters.new(params).permit
    if permitted_params[:slug].nil?
      permitted_params[:slug] = permitted_params[:title].parameterize
    end
    permitted_params[:active] = true
    permitted_params[:featured] = false
    permitted_params[:language_id] = 1
    page = CampaignPage.create! permitted_params
    template = Template.find params[:template]
    widgets = template.widget_types
    i = 0
    widgets.each do |widget|
      page.campaign_pages_widget.create!(widget_type_id: widget.id,
                                         content: {
                                          "Json" => "object", 
                                          "gets" => "populated", 
                                          "from" => "page_form.",
                                          "This field needs" => "to be unique",
                                          "so here's a UUID" => SecureRandom.uuid
                                          },
                                         page_display_order: i)
      i += 1
    end
    redirect_to page
  end

  def show
    @page = CampaignPage.find params[:id]
  end
end
