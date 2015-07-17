class CampaignPageBuilder

  def initialize(page, page_params, params)
    @page = page
    @page.attributes = page_params
    @params = params
    switch_template if switched_template?
  end

  def switched_template?
    @params[:switch_template].present?
  end

  def switch_template
    templater = PageTemplater.new(@params[:template])
    templater.convert @page
  end

  def save
    @page.save
  end

  def campaign_page
    @page
  end

end
