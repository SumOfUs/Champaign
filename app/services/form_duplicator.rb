# frozen_string_literal: true

class FormDuplicator
  class << self
    def duplicate(form)
      new(form).duplicate
    end
  end

  def initialize(form)
    @form = form
  end

  def duplicate
    @form.form_elements.each do |element|
      element = element.dup
      element.form = new_form
      element.save!
    end

    new_form
  end

  private

  def new_form
    @new_form ||= @form.dup.tap do |f|
      f.master = false
      f.save!
    end
  end
end
