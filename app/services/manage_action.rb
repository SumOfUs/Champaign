class ManageAction
  include ActionBuilder
  attr_reader :params

  def self.create(params)
    new(params).create
  end

  def initialize(params)
    @params = params
  end

  def create
    if !page.allow_duplicate_actions? && previous_action.present?
      return previous_action
    end

    build_action
  end

  private

  def page
    @page ||= Page.find(params[:page_id])
  end
end
