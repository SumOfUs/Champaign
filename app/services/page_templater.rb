class PageTemplater

  def initialize(template)
    @template = Template.find(template)
  end

  def convert page
    new_widgets = @template.widgets.map{ |w| w.dup }
    page.widgets = merge_widgets new_widgets, page.widgets
  end

  private

  def merge_widgets template_widgets, page_widgets
    # most simple solution: mark old widgets for destruction so that 
    # they still show up in the form, but as "deleted". The next level
    # is to rather than replace all page widgets, re-use those that
    # match the type of those in the template
    page_widgets.each{ |w| w.mark_for_destruction }
    return template_widgets + page_widgets
  end

end

# use cases
# - on new page, no template selected, empty widgetless form, select a template
# - on new page, have some widgets (maybe from template), want to switch to a new template
# - on edit page, have some widgets (maybe from template), want to switch to a new template
