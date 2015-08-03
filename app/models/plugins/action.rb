class Plugins::Action < ActiveRecord::Base
  belongs_to :campaign_page
  belongs_to :form

  DEFAULTS = {}

  def liquid_data
    form_fields = form.form_elements.map(&:attributes)
    attributes.merge('fields' => form_fields)
  end

  # FIXME - this was rushed. There's a nicer way to do this, I'm sure.
  #
  def name
    'Action'
  end
end
