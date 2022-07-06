class UnsafeEmailSender
  attr_reader :errors, :action

  def initialize(page_id, email_params, tracking_params = {})
    @plugin = Plugins::Email.find_by(page_id: page_id)
    @page = Page.find(page_id)
    @params = email_params.to_hash.with_indifferent_access
    # @recipients = recipients.to_hash.with_indifferent_access
    @tracking_params = tracking_params.to_hash.with_indifferent_access.slice(
      :akid, :referring_akid, :referrer_id, :rid, :source, :action_mobile
    )
    @params[:country] ||= 'US'
    @errors = {}
  end

  def run
    validate_plugin
    # validate_email_fields

    if errors.empty?
      # send_email

      create_action
    end

    errors.empty?
  end

  # def send_email
  #   EmailSender.run(
  #     id: @page.slug,
  #     recipients: to_emails,
  #     from_name: @params[:from_name],
  #     from_email: from_email,
  #     reply_to: reply_to_emails,
  #     subject: @params[:subject],
  #     body: @params[:body]
  #   )
  # end

  def existing_member
    @existing_member ||= Member.find_by_email(@params[:from_email])
  end

  def create_action
    # TODO: Not handling consent.
    # No new members for EEA countries
    @action = ManageAction.create(
      {
        page_id: @page.id,
        name: @params[:from_name],
        email: @params[:from_email],
        action_targets: @params[:recipients],
        country: @params[:country],
        # TODO: Update UI to support consent selection
        # consented: @params[:consented] || true,

        consented: existing_member ? existing_member.consented? : false,
        email_service: @params[:email_service],
        clicked_copy_body_button: @params[:clicked_copy_body_button]
      }.merge(@tracking_params)
    )
  end

  private

  def to_emails
    if @plugin.test_email_address.blank?
      [@recipient]
    else
      [{ name: 'Test Email', email: @plugin.test_email_address }]
    end
  end

  def from_email
    if @plugin.spoof_member_email?
      @params[:from_email]
    elsif @plugin.registered_email_address.present?
      @plugin.registered_email_address.email
    end
  end

  def member_email_hash
    { name: @params[:from_name], email: @params[:from_email] }
  end

  def plugin_email_from_hash
    email = @plugin.registered_email_address
    { name: email.name, email: email.email }
  end

  def reply_to_emails
    list = [plugin_email_from_hash]
    list << member_email_hash if @plugin.spoof_member_email?
    list
  end

  def validate_plugin
    add_error(:base, 'Please configure a From email address') if @params[:from_email].blank?
    add_error(:base, 'Please make sure a country is being sent') if @params[:country].blank?
  end

  def validate_email_fields
    email = EmailFieldsValidator.new(
      from_name: @params[:from_name],
      from_email: @params[:from_email],
      to_name: @recipient[:name],
      to_email: @recipient[:email],
      body: @params[:body],
      subject: @params[:subject]
    )
    email.validate
    email.errors.each { |key, msg| add_error(key, msg) }
  end

  def add_error(key, message)
    @errors[key] ||= []
    @errors[key] << message
  end
end
