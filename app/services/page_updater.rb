class PageUpdater

  def initialize(page, params={})
    @page = page
    @params = params
  end

  def update(params)
    @params, @errors, @refresh = params, {}, false
    update_plugins()
    # update_shares()
    update_page()
    @errors.empty?
  end

  def errors
    @errors
  end

  def refresh?
    @refresh || false
  end

  private

  def update_page
    return unless @params[:page]
    @page.assign_attributes(@params[:page])
    @refresh = true unless (@page.changed & refresh_triggers).empty?
    saved = @page.save
    @errors[:page] = @page.errors.to_h unless @page.errors.empty?
  end

  def update_plugin(plugin_params)
    plugin = plugins.select{|p| p.id == plugin_params[:id].to_i && p.name == plugin_params[:name] }.first
    raise ActiveRecord::RecordNotFound if plugin.blank?
    plugin.update_attributes(plugin_params.select{|k| k.to_sym != :name })
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

  def refresh_triggers
    # if one of these fields gets updated, it will break the forms, so we refresh the page
    ['liquid_layout_id']
  end

end
