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

  def list_similar(page, number: 5)
    region_tags = page.tags.region
    tags = page.tags.issue.or(region_tags)
    pages_by_tags(page.language, tags, region_tags.first, number)
    # TODO: limit to number and order by tag number
  end

  private

  def pages_by_tags(language, tags, region_tag, number)
    Page.find_by_sql("with tag_arrays AS (
    SELECT page_id,
      array_agg(tag_id) AS tag_ids,
      array_length(array_agg(tag_id) & array#{tags.pluck(:id)}, 1) AS tag_score
    FROM pages_tags
    GROUP BY page_id)
    SELECT * FROM pages
      JOIN tag_arrays
      ON pages.id = tag_arrays.page_id
      WHERE tag_ids @> ARRAY[#{region_tag.id}] AND pages.language_id = #{language.id} AND pages.publish_status = 0
    ORDER BY tag_score DESC, featured DESC
    LIMIT #{number}")
  end
end
