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
      element.save
    end

    new_form
  end

  private

  def new_form
    return @new_form || (
      @new_form = @form.dup
      @new_form.master = false
      @new_form.save
      @new_form
    )
  end
end

