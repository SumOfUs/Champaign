# frozen_string_literal: true

class ManageDonation
  def self.create(params:, extra_params: {})
    page = Page.find(params[:page_id])
    akit_donation_page_id = page.ak_donation_resource_uri.to_s.gsub(%r{/$}, '').split('/').last
    source = params[:source] || 'website'

    if page.donation_followup? && page.ak_donation_resource_uri.present?
      source = "post-action-#{akit_donation_page_id}-#{source}"
      params[:source] = source
    end

    ManageAction.create(params, extra_params: { donation: true }.merge(extra_params.clone))
  end
end
