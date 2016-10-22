# frozen_string_literal: true
module PageService
  extend self

  def list(language: nil, limit: 30)
    Page.language(language)
      .limit(limit)
      .order('updated_at desc')
      .published
  end

  def list_featured(language: nil, limit: 30)
    Page.language(language)
      .featured
      .limit(limit)
      .order('updated_at desc')
      .published
  end
end
