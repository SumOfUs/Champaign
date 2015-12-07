MagicLamp.define(controller: PagesController) do
  fixture(name: 'pages/fundraiser') do
    @page = FactoryGirl.create :page, liquid_layout: LiquidLayout.find_by(title: 'Standard Fundraiser')
    params[:id] = @page.id
    show
  end
end
