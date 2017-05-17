# frozen_string_literal: true
class ShareAnalytics
  def self.data(page, type, share)
    new(page, type, share).data
  end

  def initialize(page, type, share)
    @page = page
    @type = type
    @share = share
  end

  def data
    raw_data.select { |s| s['id'] == @share.sp_id.to_i }
  end

  def raw_data
    if button.try(:analytics)
      JSON.parse(button.analytics)['response'][0]['share_tests'][@type]
    else
      []
    end
  end

  private

  def button
    @button ||= Share::Button.find_by(page_id: @page.id, sp_type: @type)
  end
end
