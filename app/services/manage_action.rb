class ManageAction
  include ActionBuilder

  def self.create(params)
    new(params).create
  end

  def initialize(params)
    @params = params
  end

  def create
    return previous_action if previous_action.present?
    build_action
  end

  private

  def queue_message
    {
      type: 'action',
      params: {
        page: "#{page.slug}-petition"
      }.merge(@params)
    }
  end
end

