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

  def list_similar(page, language: nil, number: 10)
    tags = page.tags.issues.or(page.tags.region)
    pages = pages_by_tags(tags, language)
    pages
      .limit(number)
      .order('updated_at desc')
  end

  private

  def pages_by_tags(tags, language)
    Page.language(language).published.where(tags: tags)
  end
end
