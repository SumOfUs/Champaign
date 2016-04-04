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
end
