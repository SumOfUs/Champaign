# frozen_string_literal: true
class ClonePageError < StandardError; end

class PageCloner
  include Rails.application.routes.url_helpers

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
      shares # needs to go after images
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
    @image_id_mapping ||= {}
    primary_image = page.primary_image

    page.images.each do |image|
      new_image = Image.create(content: image.content, page: cloned_page)
      @image_id_mapping[image.id] = new_image.id
      cloned_page.primary_image = new_image if image == primary_image
    end
  end

  def shares
    page.shares.each do |share|
      ShareProgressVariantBuilder.create(
        params: share_params(share),
        variant_type: share_class(share),
        page: cloned_page,
        url: member_facing_page_url(cloned_page, host: Settings.host)
      )
    end
  end

  def share_params(share)
    case share_class(share)
    when :facebook
      facebook_params(share)
    when :twitter
      share.slice(:description)
    when :email
      share.slice(:subject, :body)
    end
  end

  def facebook_params(share)
    vals = share.slice(:description, :title, :image_id)
    if @image_id_mapping.present? && vals[:image_id].present?
      vals[:image_id] = @image_id_mapping[vals[:image_id]]
    end
    vals
  end

  def share_class(share)
    share.class.name.downcase.demodulize.to_sym
  end
end
