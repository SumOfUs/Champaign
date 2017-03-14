class Share::ButtonsController < Share::SharesController
  def update
    @page.shares.collect(&:button).uniq.each do |button|
      ShareProgressVariantBuilder.update_button_url(button, params[:share_button][:url])
    end

    render json: {sucess: true}
  end
end
