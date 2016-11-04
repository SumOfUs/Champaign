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
    @params[:choices] = format_many_choices(@params[:many_choices]) if @params[:many_choices].present?
    @params[:choices] = format_choices(@params[:choices])
    @params.merge(form: @form).except(:many_choices)
  end

  def format_many_choices(choice_string)
    return choice_string unless choice_string.present? && choice_string.is_a?(String)
    choice_string.split(/\r?\n/)
  end

  def format_choices(choice_list)
    return choice_list unless choice_list.respond_to?(:map)
    choice_list.map do |choice|
      begin
        JSON.parse(choice)
      rescue JSON::ParserError
        choice
      end
    end
  end
end
