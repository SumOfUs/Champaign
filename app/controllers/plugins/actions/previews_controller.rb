class Plugins::Actions::PreviewsController < ApplicationController

  def show
    plugin = Plugins::Action.find params[:action_id]
    render partial: 'plugins/actions/preview', locals: { plugin: plugin }
  end
end

