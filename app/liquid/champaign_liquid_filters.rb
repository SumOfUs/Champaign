module ChampaignLiquidFilters

  def select_option(tags_string, to_select)
    # if one is already selected then leave it
    return tags_string if tags_string =~ /selected/
    tags_string.gsub(/(<option.*?value=["']#{to_select}["'])(.*?)>/, '\1 selected \2>')
  end
end
