class PageUpdater

  def initialize(page)
    @page = page
  end

  def update(params)
    @params = params
    @page.update(page_params)
    @errors = @page.errors
    update_plugins()
    update_shares()

  end

  private

  def update_plugin(plugin_params)
    plugin = Plugins::Action.find(plugin_params[:id])
    plugin.update_attributes(plugin_params)
    plugin.errors
  end

  def update_share(share_params)
    ShareProgressVariantBuilder.update(permitted_params, {
      variant_type: share_params[:variant_type],
      page: @page,
      url: page_url(@page),
      id: params[:id]
    })
  end

  def update_plugins
    all_plugin_params.each do |plugin_params|
      @errors += update_plugin(plugin_params)
    end
  end

  def update_shares
    all_share_params.each do |share_params|
    end
  end

  def page_params
  end

end
