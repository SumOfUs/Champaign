module MemberEmailGuesser
  def self.run(params = {})
    referrer_id = params[:referrer_id] || params[:rid]
    referrer_akid = params[:referring_akid]

    member = Member.find_by_akid(referrer_akid) if referrer_akid.present?
    member = Member.find_by(id: referrer_id) if referrer_id.present?
    member&.email
  end
end
