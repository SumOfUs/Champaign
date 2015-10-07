class LiquidLayoutSwitcher

  def initialize(page)
    @page = page
  end

  def switch(new_layout)
    keepers, quitters, starters = find_overlap(plugin_refs_from_plugins(@page.plugins), new_layout.plugin_refs)
    delete_quitters(quitters)
    create_starters(starters)
    @page.liquid_layout = new_layout
    @page.save
  end

  private

  def delete_quitters(quitters)
    @page.plugins.each do |plugin|
      if quitters.include? [plugin.name.underscore, plugin.ref]
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
    keepers  = old_plugin_refs & new_plugin_refs
    quitters = old_plugin_refs - keepers
    starters = new_plugin_refs - keepers
    [keepers, quitters, starters]
  end

  def plugin_refs_from_plugins(plugins)
    plugins.map { |p| [p.name.underscore, p.ref] }
  end

end
