# == Schema Information
#
# Table name: plugins_call_tools
#
#  id         :integer          not null, primary key
#  page_id    :integer
#  active     :boolean
#  ref        :string
#  form_id    :integer
#  targets    :json
#  created_at :datetime
#  updated_at :datetime
#

class Plugins::CallTool < ActiveRecord::Base
  belongs_to :page, touch: true

  after_create :create_form
  belongs_to :form

  DEFAULTS = {}.freeze

  def name
    self.class.name.demodulize
  end

  def liquid_data(supplemental_data={})
    {
      active: active,
      targets: targets,
      target_countries: target_countries,
      title: title
    }
  end

  def find_target(id)
    targets.values.flatten.first do |target|
      target['id'] == id
    end
  end

  private

  def create_form
    Form.create! formable: self,
                 name: "call_tool_#{id}",
                 master: false
  end

  # Returns [{ code: <country-code>, name: <country-name>}, {..} ...]
  def target_countries
    return [] if targets.blank?
    locale = page.language&.code || :en
    targets.keys.map do |key|
      country_name = ISO3166::Country[key]&.translation(locale)
      if country_name.present?
        {
          name: country_name,
          code: key
        }
      end
    end.compact
  end
end
