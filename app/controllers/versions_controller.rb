# frozen_string_literal: true

class VersionsController < ApplicationController
  before_action :authenticate_user!

  def show
    @versions = Versions::VersionFinder.find_versions(model: params[:model], id: params[:id])
  end
end
