# frozen_string_literal: true
class ClonePageError < StandardError; end

class PageCloner
  attr_reader :page, :cloned_page, :title

  def self.clone(page, title = nil)
    new(page, title).clone
  end

  def initialize(page, title = nil)
    @page = page
    @title = title
  end

  def clone
    clone_page do
      links
      plugins
      tags
      images
    end
  end

  private

  def clone_page
    @cloned_page = page.dup
    @cloned_page.title = @title unless @title.blank?

    ActiveRecord::Base.transaction do
      @cloned_page.save! # so the new page will have an id to associate with
      yield(self)
      @cloned_page.save!
    end

    @cloned_page
  end

  def links
    page.links.each do |link|
      link.dup.tap do |clone|
        clone.page = cloned_page
        clone.save!
      end
    end
  end

  def plugins
    cloned_page.plugins.each(&:destroy)

    page.plugins.each do |plugin|
      plugin.dup.tap do |clone|
        clone.page = cloned_page
        clone.save!
      end
    end
  end

  def tags
    page.tags.each do |tag|
      cloned_page.tags << tag
    end
  end

  def images
    primary_image = page.primary_image

    page.images.each do |image|
      new_image = Image.create(content: image.content, page: cloned_page)

      cloned_page.primary_image = new_image if image == primary_image
    end
  end
end
