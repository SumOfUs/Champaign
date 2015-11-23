ActiveAdmin.register Link do
  permit_params :url, :title, :date, :source, :page_id
end
