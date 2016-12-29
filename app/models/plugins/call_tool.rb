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
      active: active
    }
  end

  private

  def create_form
    Form.create! formable: self,
                 name: "call_tool_#{id}",
                 master: false
  end
end
