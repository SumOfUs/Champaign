class PluginSettingsController < ApplicationController

  def create
    PluginSetting.create(permitted_params)

    render json: {}
  end

  def update
    setting = PluginSetting.find(params[:id])
    setting.update_attributes(permitted_params)
    render json: {}
  end


  private

  def permitted_params
    params.require(:plugin_setting).
      permit(
        :label,
        :data_type,
        :field_type,
        :help,
        :name,
        :value,
        :plugin_name,
        :campaign_page_id
    )
  end
end


