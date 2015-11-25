ActiveAdmin.register Page do
  actions :all, except: [:new, :destroy]
  permit_params :active, :featured

  index do
    selectable_column
    id_column
    column :title
    column :featured
    column :active
    column :status
    actions
  end

  form do |f|
    f.inputs 'Page Details - Edit the page in the page editor' do
      f.input :active
      f.input :featured
    end
    actions
  end

  sidebar 'Previous Versions', only: :show do
    attributes_table_for page do
      row :versions do
        link_to "There are #{page.versions.length} total versions of this page. Click here to view.", controller: '/versions', action: 'show', model: 'page', id: page.id
      end
    end
  end
end
