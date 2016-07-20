class PagePluginSwitcher

  def initialize(page)
    @page = page
  end

  def switch(new_layout, new_layout_2=nil)
    keepers, quitters, starters = find_overlap(plugin_refs_from_plugins(@page.plugins), new_refs(new_layout, new_layout_2))
    delete_quitters(quitters)
    create_starters(starters)
    @page.liquid_layout = new_layout
  end

  private

  def new_refs(layout_1, layout_2)
    return layout_1.plugin_refs if layout_2.blank?
    (layout_1.plugin_refs + layout_2.plugin_refs).uniq
  end

  def delete_quitters(quitters)
    @page.plugins.each do |plugin|
      if quitters.include? [plugin.name.underscore, plugin.ref.to_s]
        plugin.destroy!
      end
    end
  end

  def create_starters(starters)
    starters.each do |plugin_name, ref|
      Plugins.create_for_page(plugin_name, @page, ref)
    end
  end

  def find_overlap(old_plugin_refs, new_plugin_refs)
    old_plugin_refs = standardize_blank_refs(old_plugin_refs)
    new_plugin_refs = standardize_blank_refs(new_plugin_refs)
    keepers  = old_plugin_refs & new_plugin_refs
    quitters = old_plugin_refs - keepers
    starters = new_plugin_refs - keepers
    [keepers, quitters, starters]
  end

  def plugin_refs_from_plugins(plugins)
    plugins.map { |p| [p.name.underscore, p.ref] }
  end

  def standardize_blank_refs(plugin_refs)
    plugin_refs.map { |p, r| [p, r.to_s] }
  end

end

