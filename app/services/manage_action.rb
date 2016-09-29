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
    @extra_params = extra_params
  end

  def create
    if !page.allow_duplicate_actions? && previous_action.present?
      return previous_action
    end

    build_action(@extra_params)
  end

  private

  def page
    @page ||= Page.find(params[:page_id])
  end
end
