class PensionEmailSender
  def self.run(page_id, params)
    new(page_id, params).run
  end

  def initialize(page_id, params)
    @plugin ||= Plugins::EmailPension.find_by(page_id: page_id)
    @page = Page.find(page_id)
    @params = params.slice(:body, :subject, :to_email, :target_name, :from_name, :from_email)
  end

  def run
    EmailSender.run(
      id:         @page.slug,
      subject:    @params[:subject],
      body:       @params[:body],
      to:         to_emails,
      from_name:  @params[:from_name],
      from_email: from_email,
      reply_to:   reply_to_emails
    )
  end

  private

  def to_emails
    if @plugin.test_email_address.blank?
      { name: @params[:target_name], address: @params[:to_email] }
    else
      { name: 'Test', address: @plugin.test_email_address }
    end
  end

  def from_email
    if @plugin.use_member_email?
      @params[:from_email]
    elsif @plugin.from_email_address.present?
      @plugin.from_email_address.email
    end
  end

  def reply_to_emails
    list = [plugin_email_from_hash] if @plugin.from_email_address
    list << member_email_hash if @plugin.use_member_email?
    list
  end

  def member_email_hash
    { name: @params[:from_name], address: @params[:from_email] }
  end

  def plugin_email_from_hash
    email = @plugin.from_email_address
    { name: email.name, address: email.email }
  end
end
