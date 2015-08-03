class PluginSetting < ActiveRecord::Base
  belongs_to :campaign_page

  def value
    value = read_attribute('value')

    case data_type
    when 'boolean'
      value == '1'
    when 'integer'
      value.to_i
    else
      value
    end
  end
end

