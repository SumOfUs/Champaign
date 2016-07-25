json.extract! @page, :id, :title, :slug, :content, :created_at, :updated_at, :active, :featured, :action_count
json.language @page.language.code