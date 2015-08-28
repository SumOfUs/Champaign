class Plugins::Action < ActiveRecord::Base
  belongs_to :campaign_page
  belongs_to :form

  after_create :create_form

  DEFAULTS = {}

  def liquid_data
    attributes.merge('form_id' => form.try(:id),  'fields' => form_fields)
  end

  def form_fields
    form ? form.form_elements.map(&:attributes) : []
  end


  # FIXME - this was rushed. There's a nicer way to do this, I'm sure.
  #
  def name
    'Action'
  end

  private

  def create_form
    update(form: Form.create(master: false, name: "action:#{id}"))
  end
end
