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

    generate_referring_user
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
        slug: page.slug,
        body: @params
      }
    }
  end

  def generate_referring_user
    @params[:referring_user] = "/rest/v1/user/#{actionkit_user_id(@params.delete(:referring_akid))}/" if @params.has_key? :referring_akid
  end
end

