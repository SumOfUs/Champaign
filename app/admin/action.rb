ActiveAdmin.register Action do
  actions :all, except: [:new, :edit]
end
