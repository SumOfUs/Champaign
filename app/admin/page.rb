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
end
