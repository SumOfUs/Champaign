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

  def list_similar(page, limit: 5)
    region_tags = page.tags.region
    tags = page.tags.issue.or(region_tags)
    pages_by_tags(page, tags, region_tags.first, limit)
  end

  private

  def pages_by_tags(page, tags, region_tag, limit)
    # This constructs arrays of tags for each page, looks for their intersection with the original page's tags
    # and assigns that to a tag score, which is used to sort the query result. The selection is limited to
    # pages that have the region tag, are published, are not the original page and are of the same language as
    # the original page. The result is also sorted by featured status, so the first elements will be pages all the
    # matching tags issue that are featured, then pages with all the matching issue tags that are not featured,
    # then pages with some matching issue tags featured / unfeatured, and finally pages with just the region tag
    # featured / unfeatured.
    Page.find_by_sql("with tag_arrays AS (
    SELECT page_id,
      array_agg(tag_id) AS tag_ids,
      array_length(array_agg(tag_id) & array#{tags.pluck(:id)}, 1) AS tag_score
    FROM pages_tags
    GROUP BY page_id)
    SELECT * FROM pages
      JOIN tag_arrays
      ON pages.id = tag_arrays.page_id
      WHERE tag_ids @> ARRAY[#{region_tag.id}]
        AND pages.language_id = #{page.language.id}
        AND pages.publish_status = 0
        AND pages.id != #{page.id}
    ORDER BY tag_score DESC, featured DESC
    LIMIT #{limit}")
  end
end
