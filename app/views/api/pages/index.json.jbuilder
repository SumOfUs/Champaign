json.array! @pages do |page|
  json.extract! page, :id, :language, :title, :slug, :content, :created_at, :updated_at, :active, :featured, :action_count
end
