# == Schema Information
#
# Table name: plugins_emails
#
#  id                          :bigint(8)        not null, primary key
#  active                      :boolean          default(FALSE)
#  from                        :string
#  instructions                :text
#  ref                         :string
#  spoof_member_email          :boolean          default(FALSE)
#  subjects                    :string           default([]), is an Array
#  template                    :text
#  test_email_address          :string
#  title                       :string           default("")
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  page_id                     :bigint(8)
#  registered_email_address_id :bigint(8)
#
# Indexes
#
#  index_plugins_emails_on_page_id                      (page_id)
#  index_plugins_emails_on_registered_email_address_id  (registered_email_address_id)
#

require 'rails_helper'

RSpec.describe Plugins::Email, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
