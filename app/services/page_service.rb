# frozen_string_literal: true
module PageService
  extend self

  def list(language: nil, limit: 30)
    Page.language(language)
      .limit(limit)
      .order('created_at desc')
      .published
  end

  def list_featured(language: nil)
    Page.language(language)
      .featured
      .order('created_at desc')
      .published
  end
end
