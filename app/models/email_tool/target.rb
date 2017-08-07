# frozen_string_literal: true

class EmailTool::Target < Target
  set_attributes(
    :name,
    :title,
    :email
  )

  set_not_filterable_attributes(
    :email
  )

  validates :email, email: true, presence: true
  validates :name, presence: true
end
