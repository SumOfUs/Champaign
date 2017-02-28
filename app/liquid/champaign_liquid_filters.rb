# frozen_string_literal: true
module ChampaignLiquidFilters
  def select_option(tags_string, to_select)
    # if one is already selected then leave it
    return tags_string if tags_string.match?(/selected/)
    tags_string.gsub(/(<option.*?value=["']#{to_select}["'])(.*?)>/, '\1 selected \2>')
  end

  def jsonify(my_hash)
    my_hash.to_json
  end
end
