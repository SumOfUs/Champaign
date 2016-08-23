# frozen_string_literal: true
ActiveAdmin.register LiquidLayout do
  actions :all, except: [:new, :edit]

  index do
    selectable_column
    id_column
    column :title
    actions
  end

  sidebar 'Previous Versions', only: :show do
    attributes_table_for liquid_layout do
      row :versions do
        render '/versions/versions_link', model: liquid_layout, model_name: 'liquid_layout'
      end
    end
  end
end
