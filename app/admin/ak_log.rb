ActiveAdmin.register AkLog do
  actions :all, except: [:new, :edit]

  index do
    selectable_column
    id_column
    column :response_status
    column :resource
    column :created_at
  end

  filter :response_status
  filter :resource
  filter :created_at
end
