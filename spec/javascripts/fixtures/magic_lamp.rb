MagicLamp.define(controller: PagesController) do
  fixture(name: 'pages/fundraiser') do
    @page = FactoryGirl.create :page, liquid_layout: LiquidLayout.find_by(title: 'Standard Fundraiser')
    form = FactoryGirl.create :form_with_email
    @page.plugins.each { |pl| if pl.name == 'Fundraiser' then pl.update_attributes(form: form) end }
    params[:id] = @page.id
    show
  end
end
