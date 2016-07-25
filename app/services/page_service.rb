module PageService
  extend self

  def list(params = {})
    Page.language(params[:language]).
      limit(100).
      order('created_at desc').
      published
  end

  def list_featured(params = {})
    Page.language(params[:language]).
      featured.
      order('created_at desc').
      published
  end
end
