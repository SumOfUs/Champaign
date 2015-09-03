class ShareAnalytics
  def self.call(page, type, share)
    new(page, type, share).data
  end

  def initialize(page, type, share)
    @page = page
    @type = type
    @share = share
  end

  def data
    raw_data.select{|share| share['id'] == @share.sp_id.to_i}
  end

  def raw_data
    if button.analytics
      JSON.parse(button.analytics)['response'][0]['share_tests'][@type]
    else
      {}
    end
  end

  private

  def button
    @button ||= Share::Button.find_by(campaign_page_id: @page.id, sp_type: @type)
  end
end


#x['response'][0]['share_tests']['facebook']

#{"shares"=>0, "successful_shares"=>0, "conversion"=>0.0, "ci"=>0.0, "confidence"=>"--", "improvement"=>"--", "winner"=>false, "id"=>65166, "weight"=>"50.0%"}, 
#{"shares"=>1, "successful_shares"=>0, "conversion"=>0.0, "ci"=>0.0, "confidence"=>"0.0%", "improvement"=>"&#8734;", "winner"=>false, "id"=>65169, "weight"=>"50.0%"}]
