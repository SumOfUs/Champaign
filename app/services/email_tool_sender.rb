class EmailToolSender
  attr_reader :errors, :action

  def self.run(page_id, params, tracking_params = {})
    new(page_id, params, tracking_params).run
  end

  def initialize(page_id, params, tracking_params = {})
    @plugin = Plugins::EmailTool.find_by(page_id: page_id)
    @target = @plugin.find_target(params[:target_id])
    @page = Page.find(page_id)
    @params = params.slice(:from_email, :from_name, :body, :subject, :target_id, :country)
    @tracking_params = tracking_params.slice(
      :akid, :referring_akid, :referrer_id, :rid, :source, :action_mobile
    )
    @errors = {}
  end

  def run
    validate_plugin
    validate_email_fields

    if errors.empty?
      send_email
      create_action
    end

    errors.empty?
  end

  def send_email
    EmailSender.run(
      id: @page.slug,
      recipients: to_emails,
      from_name: @params[:from_name],
      from_email: from_email,
      reply_to: reply_to_emails,
      subject: @params[:subject],
      body: @params[:body]
    )
  end

  def create_action
    # TODO: Not handling consent.
    # No new members for EEA countries
    @action = ManageAction.create(
      {
        page_id: @page.id,
        name: @params[:from_name],
        email: @params[:from_email],
        action_target: @target&.name,
        action_target_email: @target&.email,
        country: @params[:country]
      }.merge(@tracking_params)
    )
  end

  private

  def to_emails
    if @plugin.test_email_address.blank?
      if @target.present?
        [{ name: @target.name, email: @target.email }]
      else
        @plugin.targets.map { |t| { name: t.name, email: t.email } }
      end
    else
      [{ name: 'Test Email', email: @plugin.test_email_address }]
    end
  end

  def from_email
    if @plugin.use_member_email?
      @params[:from_email]
    elsif @plugin.from_email_address.present?
      @plugin.from_email_address.email
    end
  end

  def member_email_hash
    { name: @params[:from_name], email: @params[:from_email] }
  end

  def plugin_email_from_hash
    email = @plugin.from_email_address
    { name: email.name, email: email.email }
  end

  def reply_to_emails
    list = [plugin_email_from_hash]
    list << member_email_hash if @plugin.use_member_email?
    list
  end

  def validate_plugin
    add_error(:base, 'Please configure a From email address') if @plugin.from_email_address.blank?

    add_error(:base, 'Please configure at least one target') if @plugin.targets.empty?

    add_error(:base, 'Please make sure a country is being sent') if @params[:country].blank?

    target_id = @params[:target_id]
    if target_id.present? && @plugin.find_target(target_id).nil?
      add_error(:base, I18n.t('email_tool.form.errors.target.outdated'))
    end
  end

  def validate_email_fields
    email = Email.new @params.slice(:from_name, :from_email, :body, :subject)
    email.validate
    email.errors.each { |key, msg| add_error(key, msg) }
  end

  def add_error(key, message)
    @errors[key] ||= []
    @errors[key] << message
  end

  class Email
    include ActiveModel::Model
    attr_accessor :from_name, :from_email, :body, :subject

    validates :from_name, presence: true
    validates :from_email, presence: true, email: true
    validates :body, presence: true, length: { minimum: 140 }
    validates :subject, presence: true
  end
end
