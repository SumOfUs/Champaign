module IsPlugin
  extend ActiveSupport::Concern

  included do
    belongs_to :page, touch: true
    belongs_to :form
  end

  def name
    self.class.name.demodulize
  end

  def plugin_liquid_data(_supplemental_data = {})
    {
      page_id: page_id,
      plugin_id: id,
      locale: page.language_code,
      active: active
    }
  end
end
