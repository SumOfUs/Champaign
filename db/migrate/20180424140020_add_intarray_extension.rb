class AddIntarrayExtension < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'intarray'
  end
end
