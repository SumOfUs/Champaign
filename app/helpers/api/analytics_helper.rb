module Api::AnalyticsHelper
  def total_actions_by_hour(page)
    map_data page.total_actions_over_time(period: :hour)
  end

  def total_actions_by_day(page)
    map_data page.total_actions_over_time(period: :day)
  end

  def new_members_by_day(page)
    map_data @page.total_actions_over_time(period: :day, new_members: true)
  end

  def map_data(data)
    data.inject([]) do |m, (k,v)|
      m << {date: k, value: v }
      m
    end
  end
end

