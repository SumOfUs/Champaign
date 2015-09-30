class AkLogsController < ApplicationController
  def index
    @items = AkLog.limit(100).order('created_at desc')
  end

  def show
  end
end
