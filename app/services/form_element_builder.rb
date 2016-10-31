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
    element.save!
    element
  end

  private

  def element
    @element ||= FormElement.new(params)
  end

  def params
    if @params[:choices].respond_to?(:map)
      @params[:choices].map! do |choice|
        begin
          JSON.parse(choice)
        rescue JSON::ParserError
          choice
        end
      end
    end
    @params.merge(form: @form)
  end
end
