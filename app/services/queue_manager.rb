# frozen_string_literal: true

class QueueManager
  include Rails.application.routes.url_helpers

  attr_reader :page, :job_type

  def self.push(page, job_type:)
    new(page, job_type).push_to_queue
  end

  def initialize(page, job_type)
    @page = page
    @job_type = job_type
  end

  def push_to_queue
    case job_type
    when :update_pages
      to_queue(
        petition_uri: page.ak_petition_resource_uri,
        donation_uri: page.ak_donation_resource_uri
      )
    when :create
      to_queue
    else
      raise ArgumentError, "job_type #{job_type} doesn't exist"
    end
  end

  private

  def to_queue(additions = {})
    ChampaignQueue.push(
      data_for_queue.merge(additions),
      group_id: "page:#{@page.id}"
    )
  end

  def data_for_queue
    {
      type: job_type,
      params: params
    }
  end

  def params
    {
      page_id:  page.id,
      name:     page.slug,
      title:    page.title,
      language: page.language.try(:actionkit_uri),
      tags:     tags,
      url:      member_facing_page_url(page, host: Settings.host),
      hosted_with: '/rest/v1/hostingplatform/2/',
      campaign_id: page.campaign_id
    }
  end

  def tags
    page.tags.map(&:actionkit_uri)
  end
end
