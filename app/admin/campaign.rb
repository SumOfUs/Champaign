ActiveAdmin.register Campaign do
  permit_params :name, :active

  index do
    selectable_column
    id_column
    column :name
    column :active
    actions
  end

  filter :name
  filter :active

  sidebar 'Previous Versions', only: :show do
    attributes_table_for campaign do
      row :versions do
        link_to "There are #{campaign.versions.length} total versions of this campaign. Click here to view.", controller: '/versions', action: 'show', model: 'campaign', id: campaign.id
      end
    end
  end
end
