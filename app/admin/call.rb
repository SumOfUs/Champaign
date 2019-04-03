# frozen_string_literal: true

ActiveAdmin.register Call do
  actions :index

  index do
    column :created_at
    column :member_phone_number
    column :target_name do |call|
      call.target.try(:name)
    end

    column :target_phone_number do |call|
      call.target.try(:phone_number)
    end

    column :target_call_status

    column :member_call_status do |call|
      CallTool::CallStatus.for(call)
    end
  end

  filter :page
  filter :member_phone_number
end
