class EmailToolSender
  attr_reader :errors

  def self.run(page_id, params)
    new(page_id, params).run
  end

  def initialize(page_id, params)
    @plugin ||= Plugins::EmailTool.find_by(page_id: page_id)
    @page = Page.find(page_id)
    @params = params.slice(:from_email, :from_name, :body, :subject, :target_id)
    @errors = {}
  end

  def run
    validate_plugin
    validate_email_fields

    if errors.blank?
      EmailSender.run(
        id: @page.slug,
        to: to_emails,
        from_name: from_email_hash[:name],
        from_email: from_email_hash[:address],
        reply_to: reply_to_emails,
        subject: @params[:subject],
        body: @params[:body]
      )
    end

    errors.blank?
  end

  private

  def to_emails
    if @plugin.test_email_address.blank?
      target = @plugin.find_target(@params[:target_id])
      if target.present?
        { name: target.name, address: target.email }
      else
        @plugin.targets.map { |t| { name: t.name, address: t.email } }
      end
    else
      { name: 'Test', address: @plugin.test_email_address }
    end
  end

  def from_email_hash
    if @plugin.use_member_email?
      member_email_hash
    elsif @plugin.from_email_address.present?
      plugin_email_from_hash
    end
  end

  def member_email_hash
    { name: @params[:from_name], address: @params[:from_email] }
  end

  def plugin_email_from_hash
    email = @plugin.from_email_address
    { name: email.name, address: email.email }
  end

  def reply_to_emails
    list = [plugin_email_from_hash]
    list << member_email_hash if @plugin.use_member_email?
    list
  end

  def validate_plugin
    if @plugin.from_email_address.blank?
      add_error(:base, 'Please configure a From email address')
    end

    if @plugin.targets.empty?
      add_error(:base, 'Please configure at least one target')
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
    validates :body, presence: true
    validates :subject, presence: true
  end
end
