# frozen_string_literal: true
# == Schema Information
#
# Table name: payment_braintree_notifications
#
#  id         :integer          not null, primary key
#  payload    :text
#  signature  :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Payment::Braintree::Notification < ActiveRecord::Base
end
