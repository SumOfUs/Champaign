ActiveAdmin.register LiquidPartial do
  actions :all, except: [:new, :edit, :destroy]

  index do
    selectable_column
    id_column
    column :title
    actions
  end

  sidebar 'Previous Versions', only: :show do
    attributes_table_for liquid_partial do
      row :versions do
        link_to "There are #{liquid_partial.versions.length} total versions of this liquid_partial. Click here to view.", controller: '/versions', action: 'show', model: 'liquid_partial', id: liquid_partial.id
      end
    end
  end
end
