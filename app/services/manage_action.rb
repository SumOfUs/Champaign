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

    ChampaignQueue.push(queue_message)
    build_action
  end

  private

  def queue_message
    {
      type: 'action',
      params: {
        slug: page.slug,
        body: @params
      }
    }
  end
end
