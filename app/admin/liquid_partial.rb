ActiveAdmin.register LiquidPartial do
  actions :all, except: [:new, :edit, :destroy]

  index do
    selectable_column
    id_column
    column :title
    actions
  end
end
