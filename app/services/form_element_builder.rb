# frozen_string_literal: true
class FormElementBuilder
  class << self
    def create(form, params)
      new(form, params).create
    end
  end

  def initialize(form, params)
    @form = form
    @params = params
  end

  def create
    element.save
    element
  end

  private

  def element
    @element ||= FormElement.new(params)
  end

  def params
    @params.merge(form: @form)
  end
end

