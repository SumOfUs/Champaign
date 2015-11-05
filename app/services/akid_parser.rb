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
    if @akid.nil? or self.invalid?
      return {actionkit_user_id: nil, mailing_id: nil}
    end

    split_akid = @akid.split('.')
    {mailing_id: split_akid[0], actionkit_user_id: split_akid[1]}
  end

  def invalid?
    if @akid.count('.') == 2
      false
    else
      true
    end
  end
end