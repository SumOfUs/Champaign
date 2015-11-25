ActiveAdmin.register Link do
  permit_params :url, :title, :date, :source, :link_id

  sidebar 'Previous Versions', only: :show do
    attributes_table_for link do
      row :versions do
        link_to "There are #{link.versions.length} total versions of this link. Click here to view.", controller: '/versions', action: 'show', model: 'link', id: link.id
      end
    end
  end
end
