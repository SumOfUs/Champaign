class Share::SharesController < ApplicationController
  before_filter :set_resource


  private

  #
  # Assigns resource name, which is taken from controller's class name.
  # +Share::TwittersController+ becomes +twitter+
  #
  def set_resource
    @resource = self.class.name.demodulize.gsub('Controller', '').downcase.singularize
  end
end
