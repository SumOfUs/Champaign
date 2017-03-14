class AddMenuSoundClipToCallTools < ActiveRecord::Migration
  def change
    add_attachment :plugins_call_tools, :menu_sound_clip
  end
end
