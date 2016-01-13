class Api::AnalyticsController < ApplicationController
  def show
    page = Analytics::Page.new( params[:page_id] )

    hours = page.total_actions_over_time(period: :hour)

    hours = hours.inject([]) do |m, (k, v)|
      m << {date: k, value: v }
      m
    end

    data = {
      hours: hours,
      days:  page.total_actions_over_time(period: :day),
      totals: {
        all: page.total_actions,
        new: page.total_actions(new_members: true)
      }
    }

    render json: { data: data }
  end
end

