# frozen_string_literal: true

class AddAttachmentToCallTool < ActiveRecord::Migration[4.2]
  def change
    add_attachment :plugins_call_tools, :sound_clip
  end
end
