module PensionFundsHelper
  def countries_list
    @countries_list ||= ISO3166::Country.all.collect { |x| { x.alpha2 => x.name } }.reduce({}, :merge)
  end

  def sorted_countries_list
    countries_list.sort_by { |_k, v| v.to_s }.collect { |x| [x.last, x.first] }
  end

  def country_name(code)
    countries_list[code]
  rescue StandardError
    ''
  end
end
