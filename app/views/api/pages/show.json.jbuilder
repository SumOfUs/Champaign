json.extract! @page, :id, :title, :slug, :content, :created_at, :updated_at, :publish_status, :featured, :action_count
json.language @page.language.code
