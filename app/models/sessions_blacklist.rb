# == Schema Information
#
# Table name: sessions_blacklists
#
#  id         :bigint(8)        not null, primary key
#  sessionid  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_sessions_blacklists_on_sessionid  (sessionid)
#

class SessionsBlacklist < ApplicationRecord
  validates :sessionid, presence: true,
                        uniqueness: { case_sensitive: false, allow_blank: true }

  def self.list(params = {})
    search_text = params[:search_text].to_s.strip
    arel = order('updated_at DESC')
    arel = arel.where('sessionid like ?', '%' + search_text + '%') if search_text.present?
    arel
  end

  def self.blacklisted?(sessionid)
    return false unless sessionid.to_s.strip.present?

    where('sessionid like ?', sessionid).present?
  end
end
