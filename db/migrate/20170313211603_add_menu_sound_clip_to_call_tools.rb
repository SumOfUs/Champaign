class AddMenuSoundClipToCallTools < ActiveRecord::Migration[4.2]
  def change
    add_attachment :plugins_call_tools, :menu_sound_clip
  end
end
