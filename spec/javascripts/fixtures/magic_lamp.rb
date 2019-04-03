# frozen_string_literal: true

MagicLamp.define(controller: PagesController) do
  fixture(name: 'pages/fundraiser') do
    @page = FactoryBot.create :page, liquid_layout: LiquidLayout.find_by(title: 'Generic Fundraiser')
    form = FactoryBot.create :form_with_email_and_optional_country
    @page.plugins.each { |pl| pl.update_attributes(form: form) if pl.name == 'Fundraiser' }
    params[:id] = @page.id
    show
  rescue StandardError => e # otherwise teaspoon will eat the error
    puts "\nError loading fixture 'pages/fundraiser': #{e.inspect}\n#{e.backtrace.first(5).join("\n")}"
    raise
  end
end

MagicLamp.define(controller: PagesController) do
  fixture(name: 'pages/petition') do
    @page = FactoryBot.create :page, liquid_layout: LiquidLayout.find_by(title: 'Generic Petition')
    form = FactoryBot.create :form_with_all_except_check
    @page.plugins.each { |pl| pl.update_attributes(form: form) if pl.name == 'Petition' }
    params[:id] = @page.id
    show
  rescue StandardError => e # otherwise teaspoon will eat the error
    puts "\nError loading fixture 'pages/petition': #{e.inspect}\n#{e.backtrace.first(5).join("\n")}"
    raise
  end
end
