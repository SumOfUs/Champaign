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

    generate_referring_user_uri
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

  def generate_referring_user_uri
    # ActionKit doesn't accept a value of "referring_akid" via the API. One can send a value of a "referring_user",
    # which is the universial resource identifier for an AK user object, in the form /rest/v1/user/actionkit_user_id/.

    # This massages that data to translate the existing referring_akid into the referring_user value that AK will happily
    # accept.
    @params[:referring_user] = "/rest/v1/user/#{actionkit_user_id(@params.delete(:referring_akid))}/" if @params.has_key? :referring_akid
  end
end

