# frozen_string_literal: true

class PagePluginSwitcher
  def initialize(page)
    @page = page
  end

  def switch(new_layout, new_layout_2 = nil)
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
      plugin.destroy! if quitters.include? [plugin.name.underscore, plugin.ref.to_s]
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
    keepers = old_plugin_refs & new_plugin_refs
    # If there's a fundraiser plugin that's kept, also keep the first donations thermometer
    keepers.append(donations_thermometer) if keepers.flatten.include? 'fundraiser'
    quitters = old_plugin_refs - keepers
    starters = new_plugin_refs - keepers
    [keepers, quitters, starters]
  end

  def donations_thermometer
    thermometer = Plugins::DonationsThermometer.where(page_id: @page.id).first
    if thermometer.nil?
      %w[donations_thermometer default]
    else
      ['donations_thermometer', thermometer.ref.to_s]
    end
  end

  def plugin_refs_from_plugins(plugins)
    plugins.map { |p| [p.name.underscore, p.ref] }
  end

  def standardize_blank_refs(plugin_refs)
    plugin_refs.map { |p, r| [p, r.to_s] }
  end
end
