class PensionEmailSender
  def self.run(page_id, params)
    new(page_id, params).run
  end

  def initialize(page_id, params)
    @plugin ||= Plugins::EmailPension.find_by(page_id: page_id)
    @page = Page.find(page_id)
    @params = params.clone
    sanitize_params
  end

  def run
    EmailSender.run(@params)
  end

  private

  def sanitize_params
    @params.slice!(:from_email, :body, :subject, :to_name,
                   :to_email, :target_name, :country, :from_name, :from_email)
    @params[:to_email] = if @plugin.test_email_address.blank?
                           @params[:to_email]
                         else
                           @plugin.test_email_address
                         end

    @params[:source_email] = @plugin.email_from
    @params[:page_slug] = @page.slug
  end
end
