# frozen_string_literal: true
MagicLamp.define(controller: PagesController) do
  fixture(name: 'pages/fundraiser') do
    begin
      @page = FactoryGirl.create :page, liquid_layout: LiquidLayout.find_by(title: 'Generic Fundraiser')
      form = FactoryGirl.create :form_with_email_and_optional_country
      @page.plugins.each { |pl| if pl.name == 'Fundraiser' then pl.update_attributes(form: form) end }
      params[:id] = @page.id
      show
    rescue StandardError => e # otherwise teaspoon will eat the error
      puts "\nError loading fixture 'pages/fundraiser': #{e.inspect}\n#{e.backtrace.first(5).join("\n")}"
      raise
    end
  end
end

MagicLamp.define(controller: PagesController) do
  fixture(name: 'pages/petition') do
    begin
      @page = FactoryGirl.create :page, liquid_layout: LiquidLayout.find_by(title: 'Generic Petition')
      form = FactoryGirl.create :form_with_all_except_check
      @page.plugins.each { |pl| if pl.name == 'Petition' then pl.update_attributes(form: form) end }
      params[:id] = @page.id
      show
    rescue StandardError => e # otherwise teaspoon will eat the error
      puts "\nError loading fixture 'pages/petition': #{e.inspect}\n#{e.backtrace.first(5).join("\n")}"
      raise
    end
  end
end
