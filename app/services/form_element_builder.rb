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
    @params[:choices] = format_many_choices if @params[:many_choices].present?
    @params[:choices] = format_choices
    @params.merge(form: @form).except(:many_choices)
  end

  def format_many_choices
    val = @params[:many_choices]
    return val unless val.present? && val.is_a?(String)
    val.split(/\r?\n/)
  end

  def format_choices
    return @params[:choices] unless @params[:choices].respond_to?(:map)
    @params[:choices].map do |choice|
      begin
        JSON.parse(choice)
      rescue JSON::ParserError
        choice
      end
    end
  end
end
