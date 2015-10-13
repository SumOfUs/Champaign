class PageUpdater

  def initialize(page, params={})
    @page = page
    @params = params
  end

  def update(params)
    puts "got params #{params}"
    @params = params
    @page.update(@params['page'])
    @errors = @page.errors.to_h
    update_plugins()
    # update_shares()
    @errors.empty?
  end

  def errors
    @errors
  end

  def refresh?
    false
  end

  private

  def update_plugin(plugin_params)
    puts "got plugin_params #{plugin_params}"
    plugin = plugins.select{|p| p.id == plugin_params[:id].to_i }.first
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
    all_plugin_params.each_pair do |name, plugin_params|
      errors = update_plugin(plugin_params)
      @errors[name] = errors.to_h unless errors.blank?
    end
  end

  def update_shares
    all_share_params.each do |share_params|
    end
  end

  def all_plugin_params
    @params.select do |key, value|
      key.to_s =~ /.*plugins.*/i
    end
  end

  def plugins
    @page.plugins
  end

end
