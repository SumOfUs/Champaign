ActiveAdmin.register Action do
  actions :all, except: [:new, :edit]

  sidebar 'Previous Versions', only: :show do
    attributes_table_for action do
      row :versions do
        link_to "There are #{action.versions.length} total versions of this action. Click here to view.", controller: '/versions', action: 'show', model: 'action', id: action.id
      end
    end
  end
end
