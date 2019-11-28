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
    return {} if member.nil? || !member_created?

    { content_name: page.slug,
      status: member_created?,
      user_id: member_id,
      page_id: page.id,
      value: member_id,
      currency: member_currency }
  end

  private

  def member_id
    member.try(:id)
  end

  def member_created?
    action.member_created
  end

  def member_currency
    return nil unless member.country

    Donations::Utils.currency_from_country_code(member.country)
  end
end
