# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_email_tools
#
#  id                    :integer          not null, primary key
#  ref                   :string
#  page_id               :integer
#  active                :boolean          default("false")
#  email_subjects        :string           default("{}"), is an Array
#  email_body            :text
#  email_body_header     :text
#  email_body_footer     :text
#  test_email_address    :string
#  targets               :json             default("{}"), is an Array
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  use_member_email      :boolean          default("false")
#  from_email_address_id :integer
#  targeting_mode        :integer          default("0")
#  title                 :string           default("")
#

class Plugins::EmailTool < ApplicationRecord
  DEFAULTS = { title: 'email_tool.title' }.freeze
  include HasTargets
  set_target_class ::EmailTool::Target

  enum targeting_mode: %i[member_selected_target all_targets]

  belongs_to :page, touch: true
  belongs_to :form
  belongs_to :from_email_address, class_name: 'RegisteredEmailAddress'

  before_create :set_from_email_address

  validates :targeting_mode, presence: true

  def name
    self.class.name.demodulize
  end

  def liquid_data(_supplemental_data = {})
    {
      active: active,
      email_body: email_body,
      email_footer: email_body_footer,
      email_header: email_body_header,
      email_subject: email_subjects.sample,
      locale: page.language_code,
      page_id: page_id,
      page: page.slug,
      targets: targets.map { |t| t.to_hash.merge(id: t.id) },
      title: title,
      use_member_email: use_member_email,
      manual_targeting: targeting_mode == 'member_selected_target'
    }
  end

  private

  def set_from_email_address
    self.from_email_address ||= RegisteredEmailAddress.first
  end
end
