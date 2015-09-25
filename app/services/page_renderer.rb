require 'render_anywhere'

class PageRenderer
  include RenderAnywhere

  def initialize(page)
    @page = page
  end

  def render_and_save
    @page.update_attributes(compiled_html: html)
  end

  private

  def html
    render partial: 'pages/page_compile', layout: false, locals: {page: @page}
  end
end
