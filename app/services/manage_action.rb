# frozen_string_literal: true
# Rename to ManageSignature
class ManageAction
  include ActionBuilder
  attr_reader :params

  def self.create(params, extra_params: {}, skip_queue: false, skip_counter: false)
    new(params, extra_params: extra_params, skip_queue: skip_queue, skip_counter: skip_counter).create
  end

  def initialize(params, extra_params: {}, skip_queue: false, skip_counter: false)
    @params = params
    @skip_queue = skip_queue
    @skip_counter = skip_counter
    @extra_attrs = extra_params
  end

  def create
    if multiple_actions_allowed?
      build_action(@extra_attrs)
    else
      previous_action
    end
  end

  private

  def multiple_actions_allowed?
    return true if is_donation? || previous_action.nil?
    page.allow_duplicate_actions?
  end

  def page
    @page ||= Page.find(params[:page_id])
  end
end
