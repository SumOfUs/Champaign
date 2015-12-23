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
    @form.form_elements.map(&:dup).
      map do |clone|
        clone.form = new_form
        clone
      end.each(&:save)

    new_form.update master: false
    new_form
  end

  private

  def new_form
    if @new_form
      @new_form
    else
      @new_form = @form.dup
      @new_form.name = @form.name + "-#{SecureRandom.uuid.to_s}"
      @new_form.save
      @new_form
    end
  end
end

