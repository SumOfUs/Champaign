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
    increment_counters
    build_action
  end

  private

  def increment_counters
    Analytics::Page.increment(page.id, new_member: !existing_member?)
  end

  def queue_message
    {
      type: 'action',
      params: {
        page: "#{page.slug}-petition"
      }.merge(@params)
    }
  end
end

