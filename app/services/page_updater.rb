class PageUpdater

  def initialize(page, page_url)
    @page = page
    @page_url = page_url
  end

  def update(params)
    @params, @errors, @refresh = params, {}, false
    @new_shares = {}
    update_plugins()
    update_shares()
    update_page()
    @errors.empty?
  end

  def errors
    @errors
  end

  def refresh?
    @refresh || false
  end

  def new_shares
    @new_shares
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
    plugin.update_attributes(without_name(plugin_params))
    plugin.errors
  end

  def update_share(share_params, name)
    params = without_name(share_params).symbolize_keys.merge({
      variant_type: share_params[:name],
      page: @page
    })
    if share_params[:id].present?
      variant = ShareProgressVariantBuilder.update(**params.merge(id: share_params[:id]))
    else
      variant = ShareProgressVariantBuilder.create(**params.merge(url: @page_url))
      @new_shares[name] = variant.id if variant.errors.blank?
    end
    variant.errors
  end

  def update_plugins
    params_for('plugins').each_pair do |name, plugin_params|
      errors = update_plugin(plugin_params)
      @errors[name] = errors.to_h unless errors.blank?
    end
  end

  def update_shares
    params_for('share').each_pair do |name, share_params|
      errors = update_share(share_params, name)
      @errors[name] = errors.to_h unless errors.blank?
    end
  end

  def params_for(query)
    @params.select do |key, value|
      key.to_s =~ /.*#{query}.*/i
    end
  end

  def plugins
    @page.plugins
  end

  def without_name(params)
    params.select{|k| k.to_sym != :name }
  end

  def refresh_triggers
    # if one of these fields gets updated, it will break the forms, so we refresh the page
    ['liquid_layout_id']
  end

end
