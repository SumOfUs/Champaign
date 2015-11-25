ActiveAdmin.register LiquidLayout do
  actions :all, except: [:new, :edit, :destroy]

  index do
    selectable_column
    id_column
    column :title
    actions
  end

  sidebar 'Previous Versions', only: :show do
    attributes_table_for liquid_layout do
      row :versions do
        link_to "There are #{liquid_layout.versions.length} total versions of this liquid_layout. Click here to view.", controller: '/versions', action: 'show', model: 'liquid_layout', id: liquid_layout.id
      end
    end
  end
end
