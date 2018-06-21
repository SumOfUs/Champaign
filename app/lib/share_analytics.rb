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
    if @share.share_progress?
      raw_data.select { |s| s['id'] == @share.sp_id.to_i }
    else
      c_rate = @share.click_count.zero? ? 'N/A' : (@share.conversion_count.to_f / @share.click_count.to_f) * 100
      @share.slice(:id, :click_count, :conversion_count).merge(weight: 'random',
                                                               conversion_rate: "#{c_rate}%")
    end
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
    @button ||= Share::Button.find_by(page_id: @page.id, share_type: @type)
  end
end
