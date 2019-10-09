class FacebookPixel
  attr_reader :page, :action, :member

  def self.completed_registration_hash(page:, action:)
    new(page, action).completed_registration_data
  end

  def initialize(page, action)
    @page = page
    @action = action
    @member = action.try(:member)
  end

  def completed_registration_data
    return {} if action.nil? || page.nil?
    return {} unless action.member_created

    { content_name: page.slug,
      status: member.present?,
      user_id: member.id,
      page_id: page.id,
      value: member.id,
      currency: member_currency }
  end

  private

  def member_currency
    Donations::Utils.currency_from_country_code(member.country)
  end
end
