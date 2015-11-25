ActiveAdmin.register Image do
  actions :all, except: [:new, :edit, :destroy]

  sidebar 'Previous Versions', only: :show do
    attributes_table_for image do
      row :versions do
        link_to "There are #{image.versions.length} total versions of this image. Click here to view.", controller: '/versions', action: 'show', model: 'image', id: image.id
      end
    end
  end
end
