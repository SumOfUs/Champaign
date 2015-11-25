ActiveAdmin.register Tag do
  permit_params :name, :actionkit_uri

  index do
    selectable_column
    id_column
    column :name
    column :actionkit_uri
    actions
  end

  filter :tags
  filter :name
  filter :actionkit_uri

  sidebar 'Previous Versions', only: :show do
    attributes_table_for tag do
      row :versions do
        link_to "There are #{tag.versions.length} total versions of this tag. Click here to view.", controller: '/versions', action: 'show', model: 'tag', id: tag.id
      end
    end
  end
end
