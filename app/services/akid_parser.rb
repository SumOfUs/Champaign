class AkidParser
  class << self
    def parse(akid)
      new(akid).parse
    end
  end

  def initialize(akid)
    @akid = akid
  end

  def parse
    return empty_response if @akid.blank? || invalid?
    mailing_id, actionkit_user_id = @akid.split('.')
    {mailing_id: mailing_id, actionkit_user_id: actionkit_user_id}
  end

  def invalid?
    @akid.count('.') != 2
  end

  private

  def empty_response
    {actionkit_user_id: nil, mailing_id: nil}
  end
end