ActiveAdmin.register Language do
  permit_params :code, :name

  sidebar 'Previous Versions', only: :show do
    attributes_table_for language do
      row :versions do
        link_to "There are #{language.versions.length} total versions of this language. Click here to view.", controller: '/versions', action: 'show', model: 'language', id: language.id
      end
    end
  end
end
